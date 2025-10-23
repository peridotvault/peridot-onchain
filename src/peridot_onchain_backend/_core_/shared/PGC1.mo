// PGC1.mo
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Nat64 "mo:base/Nat64";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Error "mo:base/Error";
import IPGC1 "./../types/IPGC1";
import TokenLedger "TokenLedger";
import PaymentService "./../services/Purchase";

shared ({ caller }) persistent actor class PGC1(
  initGameId : Text,
  initName : Text,
  initDescription : Text,
  initMetadataURI : Text,
  initPrice : Nat64,
  initMaxSupply : Nat64,
  initTokenCanister : Principal,
) = this {

  // ========== TYPES ==========
  type Platform = IPGC1.Platform;
  type Manifest = IPGC1.Manifest;
  type Hardware = IPGC1.Hardware;
  type Purchase = IPGC1.Purchase;
  type Timestamp = IPGC1.Timestamp;

  // ========== CONSTANTS ==========
  // pakai Nat (bukan Int) agar aman untuk operasi Nat
  let REFUND_WINDOW_NANOS : Time.Time = 24 * 60 * 60 * 1_000_000_000;

  // ========== STABLE STATE ==========
  let gameId : Text = initGameId;
  let maxSupply : Nat64 = initMaxSupply;
  var name : Text = initName;
  var description : Text = initDescription;
  var published : Bool = false;
  var price : Nat64 = initPrice;
  let tokenCanister : Principal = initTokenCanister;
  var totalPurchased : Nat64 = 0;
  var lifetimePurchases : Nat64 = 0;
  var lifetimeRevenue : Nat64 = 0;
  var refundableBalance : Nat64 = 0;
  var metadataURI : Text = initMetadataURI;
  let owner : Principal = caller;

  // Stable collections (HARUS stable var)
  var purchasesEntries : [(Principal, Purchase)] = [];
  var manifestsEntries : [(Platform, [Manifest])] = [];
  var liveManifestIndexEntries : [(Platform, Nat64)] = [];
  var hardwareEntries : [(Platform, Hardware)] = [];

  // ========== PLATFORM HELPERS ==========
  func platformEqual(a : Platform, b : Platform) : Bool {
    switch (a, b) {
      case (#web, #web) true;
      case (#windows, #windows) true;
      case (#macos, #macos) true;
      case (#linux, #linux) true;
      case (#android, #android) true;
      case (#ios, #ios) true;
      case (#other, #other) true;
      case _ false;
    };
  };

  func platformHash(p : Platform) : Nat32 {
    switch (p) {
      case (#web) 0;
      case (#windows) 1;
      case (#macos) 2;
      case (#linux) 3;
      case (#android) 4;
      case (#ios) 5;
      case (#other) 6; // beda dari #ios
    };
  };

  // Transient (non-stable) HashMap — dibangun ulang di postupgrade
  transient let purchases = HashMap.HashMap<Principal, Purchase>(32, Principal.equal, Principal.hash);
  transient let manifests = HashMap.HashMap<Platform, [Manifest]>(8, platformEqual, platformHash);
  transient let liveManifestIndex = HashMap.HashMap<Platform, Nat64>(8, platformEqual, platformHash);
  transient let hardware = HashMap.HashMap<Platform, Hardware>(8, platformEqual, platformHash);

  // ========== LIFECYCLE HOOKS ==========
  system func preupgrade() {
    purchasesEntries := Iter.toArray(purchases.entries());
    manifestsEntries := Iter.toArray(manifests.entries());
    liveManifestIndexEntries := Iter.toArray(liveManifestIndex.entries());
    hardwareEntries := Iter.toArray(hardware.entries());
  };

  system func postupgrade() {
    for ((k, v) in purchasesEntries.vals()) { purchases.put(k, v) };
    for ((k, v) in manifestsEntries.vals()) { manifests.put(k, v) };
    for ((k, v) in liveManifestIndexEntries.vals()) {
      liveManifestIndex.put(k, v);
    };
    for ((k, v) in hardwareEntries.vals()) { hardware.put(k, v) };
    purchasesEntries := [];
    manifestsEntries := [];
    liveManifestIndexEntries := [];
    hardwareEntries := [];
  };

  // ========== UTILS ==========
  func isOwner(c : Principal) : Bool { c == owner };

  // ========== QUERY FUNCTIONS ==========
  public query func getGameId() : async Text { gameId };
  public query func getName() : async Text { name };
  public query func getDescription() : async Text { description };
  public query func isPublished() : async Bool { published };
  public query func getPrice() : async Nat64 { price };
  public query func getMaxSupply() : async Nat64 { maxSupply };
  public query func getTotalPurchased() : async Nat64 { totalPurchased };
  public query func getLifetimeRevenue() : async Nat64 { lifetimeRevenue };
  public query func getRefundableBalance() : async Nat64 { refundableBalance };
  public query func getMetadataURI() : async Text { metadataURI };
  public query func getOwner() : async Principal { owner };
  public query func getTokenCanister() : async Principal { tokenCanister };

  public query func hasAccess(user : Principal) : async Bool {
    switch (purchases.get(user)) { case null false; case (?_) true };
  };

  public query func getAvailableSupply() : async {
    available : Nat64;
    isUnlimited : Bool;
  } {
    if (maxSupply == 0) { { available = 0; isUnlimited = true } } else {
      { available = maxSupply - totalPurchased; isUnlimited = false };
    };
  };

  public query func isUnlimited() : async Bool { maxSupply == 0 };

  public query func getLiveManifest(platform : Platform) : async ?Manifest {
    let idx : Nat64 = switch (liveManifestIndex.get(platform)) {
      case null 0;
      case (?i) i;
    };
    switch (manifests.get(platform)) {
      case null null;
      case (?manifestList) {
        if (Nat64.toNat(idx) < manifestList.size()) ?manifestList[Nat64.toNat(idx)] else null;
      };
    };
  };

  public query func getHardware(platform : Platform) : async ?Hardware {
    hardware.get(platform);
  };

  public query func getAllManifests(platform : Platform) : async [Manifest] {
    switch (manifests.get(platform)) { case null []; case (?m) m };
  };

  public query func getPurchaseInfo(user : Principal) : async ?Purchase {
    purchases.get(user);
  };

  // ========== UPDATE FUNCTIONS ==========
  public shared ({ caller }) func purchase() : async () {
    assert published;
    assert Option.isNull(purchases.get(caller));
    if (maxSupply > 0) { assert totalPurchased < maxSupply };

    // siapkan actor ledger dari principal token
    let ledger : TokenLedger.Self = actor (Principal.toText(tokenCanister));

    // escrow ke canister sendiri (refund-friendly)
    let merchant : Principal = Principal.fromActor(this);
    let spender : Principal = merchant;

    // lakukan pembayaran lewat PaymentService (cek allowance + transfer_from)
    let payRes = await PaymentService.pay(
      ledger,
      caller,
      merchant,
      spender,
      Nat64.toNat(price) // PaymentService expects Nat
    );

    switch (payRes) {
      case (#err e) { throw Error.reject("Payment failed: " # debug_show e) };
      case (#ok _txIndex) {
        // update state
        let t = Time.now();
        purchases.put(
          caller,
          {
            time = t; // IPGC1.Timestamp = Time.Time? -> kita pakai Nat64, lihat Types di bawah
            amount = price;
            tokenUsed = tokenCanister;
          },
        );
        totalPurchased += 1;
        lifetimePurchases += 1;
        lifetimeRevenue += price;
        refundableBalance += price;
        return;
      };
    };
  };

  public shared ({ caller }) func refund() : async () {
    let p = switch (purchases.get(caller)) {
      case null { throw Error.reject("Not purchased") };
      case (?v) v;
    };

    let purchasedAt : Timestamp = p.time;
    let now : Timestamp = Time.now();
    if (now > purchasedAt + REFUND_WINDOW_NANOS) {
      throw Error.reject("Refund window closed");
    };

    assert totalPurchased > 0;
    assert refundableBalance >= p.amount;

    // 🔹 KIRIM DANA DULU (jangan ubah state dulu!)
    let ledger : TokenLedger.Self = actor (Principal.toText(tokenCanister));
    let r = await ledger.icrc1_transfer({
      from_subaccount = null;
      to = { owner = caller; subaccount = null };
      amount = Nat64.toNat(p.amount);
      fee = null;
      memo = null;
      created_at_time = null;
    });

    switch (r) {
      case (#Err e) {
        // 🔹 TIDAK PERLU ROLLBACK — state belum diubah!
        throw Error.reject("Refund failed: " # debug_show e);
      };
      case (#Ok _id) {
        // 🔹 BARU UBAH STATE SETELAH SUKSES
        ignore purchases.remove(caller);
        totalPurchased -= 1;
        refundableBalance -= p.amount;
        return;
      };
    };
  };

  public shared ({ caller }) func withdrawAll() : async () {
    if (not isOwner(caller)) { throw Error.reject("Only owner") };

    let ledger : TokenLedger.Self = actor (Principal.toText(tokenCanister));
    let balNat : Nat = await ledger.icrc1_balance_of({
      owner = Principal.fromActor(this);
      subaccount = null;
    });
    let refundableNat : Nat = Nat64.toNat(refundableBalance);
    let withdrawableNat : Nat = if (balNat > refundableNat) {
      balNat - refundableNat;
    } else { 0 };

    if (withdrawableNat == 0) { throw Error.reject("No withdrawable balance") };

    let w = await ledger.icrc1_transfer({
      from_subaccount = null;
      to = { owner = owner; subaccount = null };
      amount = withdrawableNat;
      fee = null;
      memo = null;
      created_at_time = null;
    });

    switch (w) {
      case (#Err e) { throw Error.reject("Withdraw failed: " # debug_show e) };
      case (#Ok _) { return };
    };
  };

  // ========== MANAJEMEN (owner only) ==========
  public shared ({ caller }) func setPrice(newPrice : Nat64) : async () {
    if (not isOwner(caller)) { throw Error.reject("Only owner") };
    price := newPrice;
  };

  public shared ({ caller }) func appendBuild(
    platform : Platform,
    version : Text,
    sizeBytes : Nat64,
    checksum : Blob,
    createdAt : IPGC1.Timestamp,
  ) : async () {
    if (not isOwner(caller)) { throw Error.reject("Only owner") };
    assert Text.size(version) > 0;
    assert checksum.size() == 32;

    let existing = switch (manifests.get(platform)) {
      case null [];
      case (?m) m;
    };
    let newManifest : Manifest = { version; sizeBytes; checksum; createdAt };
    manifests.put(platform, Array.append(existing, [newManifest]));
  };

  public shared ({ caller }) func setHardware(
    platform : Platform,
    processor : Text,
    graphics : Text,
    memoryMB : Nat32,
    storageMB : Nat32,
    additionalNotes : Text,
  ) : async () {
    if (not isOwner(caller)) { throw Error.reject("Only owner") };
    hardware.put(platform, { processor; graphics; memoryMB; storageMB; additionalNotes });
  };

  public shared ({ caller }) func setLiveVersion(platform : Platform, manifestIndex : Nat64) : async () {
    if (not isOwner(caller)) { throw Error.reject("Only owner") };
    let list = switch (manifests.get(platform)) { case null []; case (?m) m };
    assert Nat64.toNat(manifestIndex) < list.size();
    liveManifestIndex.put(platform, manifestIndex);
  };

  public shared ({ caller }) func setPublished(isPublished : Bool) : async () {
    if (not isOwner(caller)) { throw Error.reject("Only owner") };
    published := isPublished;
  };

  public shared ({ caller }) func setMetadataURI(uri : Text) : async () {
    if (not isOwner(caller)) { throw Error.reject("Only owner") };
    metadataURI := uri;
  };

  public shared ({ caller }) func setName(newName : Text) : async () {
    if (not isOwner(caller)) { throw Error.reject("Only owner") };
    assert Text.size(newName) > 0;
    name := newName;
  };

  public shared ({ caller }) func setDescription(newDescription : Text) : async () {
    if (not isOwner(caller)) { throw Error.reject("Only owner") };
    description := newDescription;
  };
};
