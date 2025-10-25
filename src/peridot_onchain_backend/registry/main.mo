import Core "../__core__/Core";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Random "mo:base/Random";
import Buffer "mo:base/Buffer";
import GRT "types/GameRecordTypes";
import GameRecordServices "services/GameRecordServices";
import TokenLedger "../__core__/shared/TokenLedger";

persistent actor PeridotRegistry {

  /*

  ✅ register_game
  ✅ list_games

  Governance
    - gov_suspend_game
    - gov_withdraw_game
    - gov_ban_publisher
*/

  // TYPES ==========================================================
  type ApiResponse<T> = Core.ApiResponse<T>;
  type GameRecordType = GRT.GameRecord;

  // GOVERNANCE / PAYMENT CONFIG ===================================
  // Satu kali set governor; berikutnya hanya governor yang boleh ubah config.
  private var gov : ?Principal = null;
  private var admins : [Principal] = [];

  // fee $10 dalam smallest unit. ckUSDT umumnya 6 desimal => 10 * 10^6.
  private var fee_amount : Nat = 10_000_000; // 10 USDT (6 decimals)
  private var fee_token_address : ?Principal = null;
  private var fee_decimals : Nat8 = 6;
  private var treasury_address : ?Principal = null;

  // SNAPSHOTS ======================================================
  private var gameRecordEntries : [(Core.GameId, GameRecordType)] = [];
  private var activeVoucherEntries : [Text] = [];
  private var adminEntries : [Principal] = [];

  // STATE ==========================================================
  private transient var gameRecords : GRT.GameRecordHashMap = HashMap.HashMap(8, Text.equal, Text.hash);
  private transient var activeVouchers : HashMap.HashMap<Text, ()> = HashMap.HashMap(32, Text.equal, Text.hash);

  // SYSTEM =========================================================
  system func preupgrade() {
    gameRecordEntries := Iter.toArray(gameRecords.entries());
    activeVoucherEntries := Iter.toArray(activeVouchers.keys());
    adminEntries := admins;
  };

  system func postupgrade() {
    gameRecords := HashMap.fromIter<Core.GameId, GameRecordType>(
      gameRecordEntries.vals(),
      8,
      Text.equal,
      Text.hash,
    );
    for (hash in activeVoucherEntries.vals()) {
      activeVouchers.put(hash, ());
    };
    admins := adminEntries;

    gameRecordEntries := [];
    activeVoucherEntries := [];
    adminEntries := [];
  };

  // ================================================================
  // Authority Helpers ==============================================
  // ================================================================

  // 🔹 Check if caller is governor
  private func isGovernor(caller : Principal) : Bool {
    switch (gov) {
      case (?g) Principal.equal(caller, g);
      case null false;
    };
  };

  // 🔹 Check if caller is admin
  private func isAdmin(caller : Principal) : Bool {
    Array.find<Principal>(admins, func(a) { Principal.equal(a, caller) }) != null;
  };

  // 🔹 Check if caller has voucher authority (governor OR admin)
  private func hasVoucherAuthority(caller : Principal) : Bool {
    isGovernor(caller) or isAdmin(caller);
  };

  // ================================================================
  // Admin Management ===============================================
  // ================================================================

  public shared ({ caller }) func add_admin(admin : Principal) : async ApiResponse<Bool> {
    if (not isGovernor(caller)) {
      return #err(#NotAuthorized("Only governor can add admins"));
    };

    if (isAdmin(admin)) {
      return #err(#ValidationError("Principal is already an admin"));
    };

    admins := Array.append(admins, [admin]);
    #ok(true);
  };

  public shared ({ caller }) func remove_admin(admin : Principal) : async ApiResponse<Bool> {
    if (not isGovernor(caller)) {
      return #err(#NotAuthorized("Only governor can remove admins"));
    };

    if (not isAdmin(admin)) {
      return #err(#NotFound("Principal is not an admin"));
    };

    admins := Array.filter<Principal>(admins, func(a) { not Principal.equal(a, admin) });
    #ok(true);
  };

  public query func get_admins() : async [Principal] {
    admins;
  };

  // ================================================================
  // Business =======================================================
  // ================================================================
  func pow10(n : Nat8) : Nat {
    var r : Nat = 1;
    var i : Nat = Nat8.toNat(n);
    while (i > 0) { r *= 10; i -= 1 };
    r;
  };

  func fetchTokenDecimals(token : Principal) : async Nat8 {
    let l : TokenLedger.Self = actor (Principal.toText(token));

    // Attempt 1: icrc1_decimals
    try {
      let d = await l.icrc1_decimals();
      return d;
    } catch (_) {};

    // Attempt 2: metadata
    try {
      let md = await l.icrc1_metadata();
      label scan for ((k, v) in md.vals()) {
        if (k == "icrc1:decimals" or k == "decimals") {
          switch (v) {
            case (#Nat n) { return Nat8.fromNat(n) };
            case _ {};
          };
        };
      };
      return 6 : Nat8;
    } catch (_) {
      return 6 : Nat8;
    };
  };

  public shared ({ caller }) func set_governor(p : Principal) : async Bool {
    switch (gov) {
      case (null) { gov := ?p; true };
      case (?g) { if (caller == g) { gov := ?p; true } else { false } };
    };
  };

  public query func get_governor() : async ?Principal {
    gov;
  };

  public shared ({ caller }) func set_payment_config(
    token : Principal,
    usd_units : Nat,
    dest : Principal,
  ) : async Bool {
    switch (gov) {
      case (?g) { if (caller != g) return false };
      case null { return false };
    };

    let dec : Nat8 = await fetchTokenDecimals(token);
    let amount_smallest : Nat = usd_units * pow10(dec);

    fee_token_address := ?token;
    fee_decimals := dec;
    fee_amount := amount_smallest;
    treasury_address := ?dest;
    true;
  };

  public query func get_payment_config() : async {
    token : ?Principal;
    amount_smallest : Nat;
    decimals : Nat8;
  } {
    {
      token = fee_token_address;
      amount_smallest = fee_amount;
      decimals = fee_decimals;
    };
  };

  // ================================================================
  // Voucher - Random Code Generator ================================
  // ================================================================

  // 🔹 Generate random alphanumeric code
  private func generateRandomCode(length : Nat, seed : Blob) : Text {
    let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    let charsArray = Text.toArray(chars);
    let charsLen = charsArray.size();

    var code = "";
    var currentSeed = seed;

    var i = 0;
    while (i < length) {
      let rand = Random.Finite(currentSeed);

      switch (rand.byte()) {
        case (?byte) {
          let index = Nat8.toNat(byte) % charsLen;
          let char = charsArray[index];
          code #= Text.fromChar(char);

          // Update seed untuk iterasi berikutnya
          currentSeed := Blob.fromArray([byte]);
        };
        case null {
          // Fallback jika random gagal
          code #= "X";
        };
      };

      i += 1;
    };

    code;
  };

  // 🔹 Generate multiple unique voucher codes
  public shared ({ caller }) func generate_vouchers(
    count : Nat,
    codeLength : ?Nat,
  ) : async ApiResponse<[Text]> {
    if (not hasVoucherAuthority(caller)) {
      return #err(#NotAuthorized("Only governor or admin can generate vouchers"));
    };

    if (count == 0 or count > 100) {
      return #err(#ValidationError("Count must be between 1 and 100"));
    };

    let len = switch (codeLength) {
      case (?l) if (l < 6 or l > 20) 12 else l;
      case null 12;
    };

    let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    let generatedCodes = Buffer.Buffer<Text>(count);
    let maxAttempts = count * 20; // naikkan sedikit
    var attempts = 0;

    label generation while (generatedCodes.size() < count and attempts < maxAttempts) {
      attempts += 1;

      // ✅ Ambil random blob baru setiap iterasi
      let randomBlob = await Random.blob();
      var randomBytes = Blob.toArray(randomBlob);
      var code = "";

      var i = 0;
      var byteIndex = 0;
      while (i < len) {
        if (byteIndex >= randomBytes.size()) {
          // Jika kehabisan byte, ambil baru
          let extra = await Random.blob();
          randomBytes := Array.append(randomBytes, Blob.toArray(extra));
        };

        let byte = randomBytes[byteIndex];
        let index = Nat8.toNat(byte) % chars.size();
        code #= Text.fromChar(Text.toArray(chars)[index]);
        byteIndex += 1;
        i += 1;
      };

      // Cek duplikat (di state + di batch)
      if (activeVouchers.get(code) == null) {
        var isDuplicate = false;
        for (c in generatedCodes.vals()) {
          if (Text.equal(c, code)) {
            isDuplicate := true;
          };
        };
        if (not isDuplicate) {
          activeVouchers.put(code, ());
          generatedCodes.add(code);
        };
      };
    };

    if (generatedCodes.size() < count) {
      return #err(#ValidationError("Failed to generate unique vouchers. Try smaller count or longer code length."));
    };

    #ok(Buffer.toArray(generatedCodes));
  };

  public shared query ({ caller }) func list_vouchers() : async ApiResponse<[Text]> {
    if (not hasVoucherAuthority(caller)) {
      return #err(#NotAuthorized("Only governor or admin can list vouchers"));
    };
    #ok(Iter.toArray(activeVouchers.keys()));
  };

  // ================================================================
  // Voucher - Manual Creation ======================================
  // ================================================================

  // 🔹 Create single voucher with custom code (governor OR admin)
  public shared ({ caller }) func create_voucher(code : Text) : async ApiResponse<Bool> {
    // Check authority (governor OR admin)
    if (not hasVoucherAuthority(caller)) {
      return #err(#NotAuthorized("Only governor or admin can create vouchers"));
    };

    if (Text.size(code) < 4) {
      return #err(#ValidationError("Voucher code must be at least 4 characters"));
    };

    // Check if voucher already exists
    if (activeVouchers.get(code) != null) {
      return #err(#ValidationError("Voucher code already exists"));
    };

    activeVouchers.put(code, ());
    #ok(true);
  };

  // 🔹 Redeem voucher untuk register game gratis
  public shared ({ caller }) func redeem_voucher(
    code : Text,
    createGameRecord : GRT.CreateGameRecord,
  ) : async ApiResponse<GameRecordType> {

    // 1️⃣ Cek apakah voucher aktif
    if (activeVouchers.get(code) == null) {
      return #err(#NotFound("Invalid or expired voucher"));
    };

    // 2️⃣ Verifikasi caller adalah owner PGC1 SEBELUM hapus voucher
    let pgc1 : actor {
      getOwner : () -> async Principal;
    } = actor (Principal.toText(createGameRecord.canister_id));

    ignore activeVouchers.remove(code);
    let owner = try {
      await pgc1.getOwner();
    } catch (_) {
      activeVouchers.put(code, ());
      return #err(#ValidationError("Failed to verify canister ownership"));
    };

    if (owner != caller) {
      return #err(#NotAuthorized("Caller must be PGC1 owner"));
    };

    // 3️⃣ Register game (jika gagal, voucher tidak dihapus)
    let registerResult = await GameRecordServices.register_game(
      gameRecords,
      caller,
      createGameRecord,
    );

    // 4️⃣ HANYA hapus voucher jika registrasi berhasil
    switch (registerResult) {
      case (#ok gameRecord) {
        #ok(gameRecord);
      };
      case (#err e) {
        // Voucher tetap valid jika registrasi gagal
        #err(e);
      };
    };
  };

  // 🔹 Revoke/delete voucher (governor OR admin)
  public shared ({ caller }) func revoke_voucher(code : Text) : async ApiResponse<Bool> {
    if (not hasVoucherAuthority(caller)) {
      return #err(#NotAuthorized("Only governor or admin can revoke vouchers"));
    };

    switch (activeVouchers.remove(code)) {
      case (?_) #ok(true);
      case null #err(#NotFound("Voucher not found"));
    };
  };

  // 🔹 Query voucher status
  public query func is_voucher_valid(code : Text) : async Bool {
    activeVouchers.get(code) != null;
  };

  // 🔹 List active vouchers count (governor OR admin)
  public shared query ({ caller }) func get_voucher_count() : async ApiResponse<Nat> {
    if (not hasVoucherAuthority(caller)) {
      return #err(#NotAuthorized("Only governor or admin can view voucher stats"));
    };

    #ok(activeVouchers.size());
  };

  // ================================================================
  // Game Record ====================================================
  // ================================================================
  public shared ({ caller }) func register_game_with_fee(
    createGameRecord : GRT.CreateGameRecord
  ) : async ApiResponse<GameRecordType> {
    let peridotRegistry = Principal.fromActor(PeridotRegistry);
    await GameRecordServices.register_game_with_fee(gameRecords, caller, createGameRecord, fee_amount, fee_token_address, treasury_address, peridotRegistry);
  };

  public func register_game_with_fee_for(createGameRecord : GRT.CreateGameRecord, payer : Principal) : async ApiResponse<GameRecordType> {
    let peridotRegistry = Principal.fromActor(PeridotRegistry);
    await GameRecordServices.register_game_with_fee_for(gameRecords, createGameRecord, fee_amount, fee_token_address, treasury_address, peridotRegistry, payer);
  };

  public query func isGameRegistered(canisterId : Principal) : async Bool {
    GameRecordServices.isGameRegistered(gameRecords, canisterId);
  };

  public query func getGameRecordById(gameId : Core.GameId) : async ApiResponse<GameRecordType> {
    GameRecordServices.getGameRecordById(gameRecords, gameId);
  };

  public query func getAllGameRecord() : async ApiResponse<[GameRecordType]> {
    GameRecordServices.getAllGameRecord(gameRecords);
  };

  public query func getAllGameRecordLimit(start : Nat, limit : Nat) : async ApiResponse<[GameRecordType]> {
    GameRecordServices.getAllGameRecordLimit(gameRecords, start, limit);
  };

  public shared func getGameByDeveloperId(dev : Principal, gameId : Core.GameId) : async ApiResponse<GameRecordType> {
    await GameRecordServices.getGameByDeveloperId(gameRecords, dev, gameId);
  };

};
