import Core "../_core_/Core";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import GRT "types/GameRecordTypes";
import GameRecordServices "services/GameRecordServices";
import TokenLedger "../_core_/shared/TokenLedger";

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

  // fee $10 dalam smallest unit. ckUSDT umumnya 6 desimal => 10 * 10^6.
  private var fee_amount : Nat = 10_000_000; // 10 USDT (6 decimals)
  private var fee_token_address : ?Principal = null;
  private var fee_decimals : Nat8 = 6;
  private var treasury_address : ?Principal = null;

  // SNAPSHOTS ======================================================
  private var gameRecordEntries : [(Core.GameId, GameRecordType)] = [];

  // STATE ==========================================================
  private transient var gameRecords : GRT.GameRecordHashMap = HashMap.HashMap(8, Text.equal, Text.hash);

  // SYSTEM =========================================================
  system func preupgrade() {
    gameRecordEntries := Iter.toArray(gameRecords.entries());
  };

  system func postupgrade() {
    gameRecords := HashMap.fromIter<Core.GameId, GameRecordType>(
      gameRecordEntries.vals(),
      8,
      Text.equal,
      Text.hash,
    );

    gameRecordEntries := [];
  };

  // ================================================================
  // Business =======================================================
  // ================================================================
  func pow10(n : Nat8) : Nat {
    var r : Nat = 1;
    var i : Nat = Nat8.toNat(n); // <= perbaikan (bukan Nat.fromNat8)
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
            case (#Nat n) { return Nat8.fromNat(n) }; // <= perbaikan (bukan Nat.toNat8)
            case _ {}; // lanjut scan
          };
        };
      };
      // jika key tidak ketemu, pakai default
      return 6 : Nat8;
    } catch (_) {
      return 6 : Nat8; // <= literal Nat8
    };
  };

  public shared ({ caller }) func set_governor(p : Principal) : async Bool {
    switch (gov) {
      case (null) { gov := ?p; true };
      case (?g) { if (caller == g) { gov := ?p; true } else { false } };
    };
  };

  public shared ({ caller }) func set_payment_config(
    token : Principal,
    usd_units : Nat, // contoh: 10 untuk $10
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
