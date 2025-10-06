import Core "../_core_/Core";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import GRT "types/GameRecordTypes";
import GameRecordServices "services/GameRecordServices";

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

  // SNAPSHOTS ======================================================
  private var gameRecordEntries : [(Core.GameId, GameRecordType)] = [];

  // STATE ==========================================================
  private transient var gameRecords : GRT.GameRecordHashMap = HashMap.HashMap(8, Text.equal, Text.hash);

  // SYSTEM =========================================================
  system func preupgrade() {
    gameRecordEntries := Iter.toArray(gameRecords.entries());
  };

  system func postupgrade() {
    gameRecords := HashMap.fromIter<Core.GameId, GameRecordType>(gameRecordEntries.vals(), 8, Text.equal, Text.hash);

    gameRecordEntries := [];
  };

  // ================================================================
  // Game Record ====================================================
  // ================================================================
  public shared func register_game(createGameRecord : GRT.CreateGameRecord) : async ApiResponse<GameRecordType> {
    await GameRecordServices.register_game(gameRecords, createGameRecord);
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

};
