// PGC1.mo - Fixed Version
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
import Result "mo:base/Result";
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
  initVaultCanister : Principal, // 🔹 TAMBAHAN: PeridotVault
) = this {

  // ========== TYPES ==========
  type Platform = IPGC1.Platform;
  type Manifest = IPGC1.Manifest;
  type Hardware = IPGC1.Hardware;
  type Purchase = IPGC1.Purchase;
  type Timestamp = IPGC1.Timestamp;

  // 🔹 Return types yang jelas
  public type PurchaseResult = {
    #success : { txIndex : Nat; timestamp : Timestamp };
    #alreadyOwned;
    #notPublished;
    #soldOut;
    #paymentFailed : Text;
    #insufficientAllowance;
  };

  public type RefundResult = {
    #success : { amount : Nat64 };
    #notOwned;
    #windowClosed;
    #transferFailed : Text;
  };

  public type WithdrawResult = {
    #success : { amount : Nat; vaultShare : Nat };
    #unauthorized;
    #noBalance;
    #transferFailed : Text;
  };

  // ========== CONSTANTS ==========
  let REFUND_WINDOW_NANOS : Time.Time = 8 * 60 * 60 * 1_000_000_000; // 8 Hours
  let VAULT_FEE_PERCENTAGE : Nat = 10; // 10% untuk PeridotVault

  // ========== STABLE STATE ==========
  let gameId : Text = initGameId;
  let maxSupply : Nat64 = initMaxSupply;
  var name : Text = initName;
  var description : Text = initDescription;
  var published : Bool = false;
  var price : Nat64 = initPrice;
  let tokenCanister : Principal = initTokenCanister;
  let vaultCanister : Principal = initVaultCanister;
  var totalPurchased : Nat64 = 0;
  var lifetimePurchases : Nat64 = 0;
  var lifetimeRevenue : Nat64 = 0;
  var refundableBalance : Nat64 = 0;
  var withdrawnBalance : Nat64 = 0; // 🔹 Track total withdrawn
  var metadataURI : Text = initMetadataURI;
  let owner : Principal = caller;

  // Stable collections
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
      case (#other) 6;
    };
  };

  // Transient HashMaps
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
  public query func isFree() : async Bool { price == 0 }; // 🔹 NEW
  public query func getMaxSupply() : async Nat64 { maxSupply };
  public query func getTotalPurchased() : async Nat64 { totalPurchased };
  public query func getLifetimeRevenue() : async Nat64 { lifetimeRevenue };
  public query func getRefundableBalance() : async Nat64 { refundableBalance };
  public query func getWithdrawnBalance() : async Nat64 { withdrawnBalance }; // 🔹 NEW
  public query func getMetadataURI() : async Text { metadataURI };
  public query func getOwner() : async Principal { owner };
  public query func getTokenCanister() : async Principal { tokenCanister };
  public query func getVaultCanister() : async Principal { vaultCanister }; // 🔹 NEW

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

  // 🔹 FIXED: Purchase dengan return type jelas + support FREE games
  public shared ({ caller }) func purchase() : async PurchaseResult {
    // Validasi: game harus published
    if (not published) { return #notPublished };

    // Validasi: user belum punya akses
    if (Option.isSome(purchases.get(caller))) { return #alreadyOwned };

    // Validasi: cek supply (jika bukan unlimited)
    if (maxSupply > 0 and totalPurchased >= maxSupply) { return #soldOut };

    let t = Time.now();

    // 🔹 CASE 1: Game FREE (price = 0) — langsung grant akses
    if (price == 0) {
      purchases.put(
        caller,
        {
          time = t;
          amount = 0;
          tokenUsed = tokenCanister;
        },
      );
      totalPurchased += 1;
      lifetimePurchases += 1;
      return #success({ txIndex = 0; timestamp = t });
    };

    // 🔹 CASE 2: Game PAID — lakukan pembayaran
    let ledger : TokenLedger.Self = actor (Principal.toText(tokenCanister));
    let merchant : Principal = Principal.fromActor(this);
    let spender : Principal = merchant;

    let payRes = await PaymentService.pay(
      ledger,
      caller,
      merchant,
      spender,
      Nat64.toNat(price),
    );

    switch (payRes) {
      case (#err e) {
        switch (e) {
          case (#NotAuthorized(_msg)) { return #insufficientAllowance };
          case (#StorageError(msg)) { return #paymentFailed(msg) };
          case _ { return #paymentFailed("Unknown error") };
        };
      };
      case (#ok txIndex) {
        // Simpan purchase record
        purchases.put(
          caller,
          {
            time = t;
            amount = price;
            tokenUsed = tokenCanister;
          },
        );
        totalPurchased += 1;
        lifetimePurchases += 1;
        lifetimeRevenue += price;
        refundableBalance += price;
        return #success({ txIndex = txIndex; timestamp = t });
      };
    };
  };

  // 🔹 FIXED: Refund dengan return type jelas
  public shared ({ caller }) func refund() : async RefundResult {
    let p = switch (purchases.get(caller)) {
      case null { return #notOwned };
      case (?v) v;
    };

    // Free game tidak bisa refund
    if (p.amount == 0) { return #notOwned };

    let purchasedAt : Timestamp = p.time;
    let now : Timestamp = Time.now();
    if (now > purchasedAt + REFUND_WINDOW_NANOS) {
      return #windowClosed;
    };

    assert totalPurchased > 0;
    assert refundableBalance >= p.amount;

    // Transfer refund dulu
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
        return #transferFailed(debug_show e);
      };
      case (#Ok _id) {
        // Update state setelah sukses
        ignore purchases.remove(caller);
        totalPurchased -= 1;
        refundableBalance -= p.amount;
        return #success({ amount = p.amount });
      };
    };
  };

  // 🔹 FIXED: Withdraw dengan revenue sharing 10% ke PeridotVault
  public shared ({ caller }) func withdrawAll() : async WithdrawResult {
    if (not isOwner(caller)) { return #unauthorized };

    let ledger : TokenLedger.Self = actor (Principal.toText(tokenCanister));

    // Hitung balance yang bisa ditarik
    let balNat : Nat = await ledger.icrc1_balance_of({
      owner = Principal.fromActor(this);
      subaccount = null;
    });
    let refundableNat : Nat = Nat64.toNat(refundableBalance);
    let withdrawableNat : Nat = if (balNat > refundableNat) {
      balNat - refundableNat;
    } else { 0 };

    if (withdrawableNat == 0) { return #noBalance };

    // 🔹 HITUNG: 10% untuk Vault, 90% untuk Developer
    let vaultShare : Nat = (withdrawableNat * VAULT_FEE_PERCENTAGE) / 100;
    let developerShare : Nat = withdrawableNat - vaultShare;

    // 1️⃣ Kirim ke PeridotVault (10%)
    if (vaultShare > 0) {
      let vaultTransfer = await ledger.icrc1_transfer({
        from_subaccount = null;
        to = { owner = vaultCanister; subaccount = null };
        amount = vaultShare;
        fee = null;
        memo = null;
        created_at_time = null;
      });

      switch (vaultTransfer) {
        case (#Err e) {
          return #transferFailed("Vault transfer failed: " # debug_show e);
        };
        case (#Ok _) {};
      };
    };

    // 2️⃣ Kirim ke Developer (90%)
    let devTransfer = await ledger.icrc1_transfer({
      from_subaccount = null;
      to = { owner = owner; subaccount = null };
      amount = developerShare;
      fee = null;
      memo = null;
      created_at_time = null;
    });

    switch (devTransfer) {
      case (#Err e) {
        return #transferFailed("Developer transfer failed: " # debug_show e);
      };
      case (#Ok _) {
        withdrawnBalance += Nat64.fromNat(withdrawableNat);
        return #success({ amount = developerShare; vaultShare = vaultShare });
      };
    };
  };

  // ========== MANAJEMEN (owner only) ==========
  public shared ({ caller }) func setPrice(newPrice : Nat64) : async Result.Result<(), Text> {
    if (not isOwner(caller)) { return #err("Only owner") };
    price := newPrice;
    #ok();
  };

  public shared ({ caller }) func appendBuild(
    platform : Platform,
    version : Text,
    sizeBytes : Nat64,
    checksum : Blob,
    createdAt : IPGC1.Timestamp,
  ) : async Result.Result<(), Text> {
    if (not isOwner(caller)) { return #err("Only owner") };
    if (Text.size(version) == 0) { return #err("Version cannot be empty") };
    if (checksum.size() != 32) { return #err("Checksum must be 32 bytes") };

    let existing = switch (manifests.get(platform)) {
      case null [];
      case (?m) m;
    };
    let newManifest : Manifest = { version; sizeBytes; checksum; createdAt };
    manifests.put(platform, Array.append(existing, [newManifest]));
    #ok();
  };

  public shared ({ caller }) func setHardware(
    platform : Platform,
    processor : Text,
    graphics : Text,
    memoryMB : Nat32,
    storageMB : Nat32,
    additionalNotes : Text,
  ) : async Result.Result<(), Text> {
    if (not isOwner(caller)) { return #err("Only owner") };
    hardware.put(platform, { processor; graphics; memoryMB; storageMB; additionalNotes });
    #ok();
  };

  public shared ({ caller }) func setLiveVersion(platform : Platform, manifestIndex : Nat64) : async Result.Result<(), Text> {
    if (not isOwner(caller)) { return #err("Only owner") };
    let list = switch (manifests.get(platform)) { case null []; case (?m) m };
    if (Nat64.toNat(manifestIndex) >= list.size()) {
      return #err("Invalid manifest index");
    };
    liveManifestIndex.put(platform, manifestIndex);
    #ok();
  };

  public shared ({ caller }) func setPublished(isPublished : Bool) : async Result.Result<(), Text> {
    if (not isOwner(caller)) { return #err("Only owner") };
    published := isPublished;
    #ok();
  };

  public shared ({ caller }) func setMetadataURI(uri : Text) : async Result.Result<(), Text> {
    if (not isOwner(caller)) { return #err("Only owner") };
    metadataURI := uri;
    #ok();
  };

  public shared ({ caller }) func setName(newName : Text) : async Result.Result<(), Text> {
    if (not isOwner(caller)) { return #err("Only owner") };
    if (Text.size(newName) == 0) { return #err("Name cannot be empty") };
    name := newName;
    #ok();
  };

  public shared ({ caller }) func setDescription(newDescription : Text) : async Result.Result<(), Text> {
    if (not isOwner(caller)) { return #err("Only owner") };
    description := newDescription;
    #ok();
  };
};
