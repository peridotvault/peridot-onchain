import PeridotDirectory "canister:peridot_directory";

import GRT "../types/GameRecordTypes";
import PGL1 "../../_core_/shared/PGL1Ledger";

import Helpers "../../_core_/Helpers";

import Core "../../_core_/Core";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";

module GameRecordService {
  // TYPES ==========================================================
  type ApiResponse<T> = Core.ApiResponse<T>;
  type GameRecordType = GRT.GameRecord;

  public func register_game(gameRecords : GRT.GameRecordHashMap, createGameRecord : GRT.CreateGameRecord) : async ApiResponse<GameRecordType> {
    let pgl1 : PGL1.PGL1Ledger = actor (Principal.toText(createGameRecord.canister_id));
    var controllers = await pgl1.get_controllers();

    // TODO : if developer PeridotVault == developer PGL (its okay caller != developer PeridotVault)
    switch (controllers.developer) {
      case (null) {
        #err(#Unauthorized("Forbidden: you are not the developer of this app"));
      };
      case (?p) {
        // TODO : update protected
        let isDeveloper = await PeridotDirectory.isUserDeveloper(p);
        assert (p == createGameRecord.developer and isDeveloper);
        // assert (p == createGameRecord.developer);

        let gameRecordNewData : GameRecordType = {
          game_id = await pgl1.pgl1_game_id();
          canister_id = createGameRecord.canister_id;
          developer = createGameRecord.developer;
          status = null; // GOV SUSPEND
          register_at = Time.now();
        };

        // Store game data
        gameRecords.put(gameRecordNewData.game_id, gameRecordNewData);
        #ok(gameRecordNewData);
      };
    };

  };

  public func isGameRegistered(
    gameRecords : GRT.GameRecordHashMap,
    canisterId : Principal,
  ) : Bool {
    var found = false;
    label scan for ((_, rec) in gameRecords.entries()) {
      if (Principal.equal(rec.canister_id, canisterId)) {
        found := true;
        break scan;
      };
    };
    found;
  };

  public func getAllGameRecordLimit(
    gameRecords : GRT.GameRecordHashMap,
    start : Nat,
    limit : Nat,
  ) : ApiResponse<[GameRecordType]> {
    #ok(Helpers.sliceIter<GameRecordType>(gameRecords.vals(), start, limit));
  };

  public func getAllGameRecord(
    gameRecords : GRT.GameRecordHashMap
  ) : ApiResponse<[GameRecordType]> {
    #ok(Iter.toArray<GameRecordType>(gameRecords.vals()));
  };

  public func getGameRecordById(
    gameRecords : GRT.GameRecordHashMap,
    gameId : Core.GameId,
  ) : ApiResponse<GameRecordType> {
    switch (gameRecords.get(gameId)) {
      case (null) {
        #err(#NotFound("Game with Game Id " # gameId # " not registered"));
      };
      case (?game) { #ok(game) };
    };
  };
};
