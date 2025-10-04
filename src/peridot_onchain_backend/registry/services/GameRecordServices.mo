import GRT "../types/GameRecordTypes";

import Helpers "../../_core_/Helpers";

import Core "../../_core_/Core";
import Time "mo:base/Time";
import Principal "mo:base/Principal";

module GameRecordService {
  // TYPES ==========================================================
  type ApiResponse<T> = Core.ApiResponse<T>;
  type GameRecordType = GRT.GameRecord;

  public func register_game(gameRecords : GRT.GameRecordHashMap, caller : Principal, createGameRecord : GRT.CreateGameRecord) : async ApiResponse<GameRecordType> {

    // TODO : if developer PeridotVault == developer PGL (its okay caller != developer PeridotVault)
    assert (caller == createGameRecord.developer);
    // let isUserDeveloper = await PeridotUser.getDeveloperProfile(developerId);

    // switch (isUserDeveloper) {
    //   case (#err(error)) {
    //     return #err(error);
    //   };
    //   case (#ok(_dev)) {};
    // };

    let gameRecordNewData : GameRecordType = {
      game_id = createGameRecord.game_id;
      canister_id = createGameRecord.canister_id;
      developer = createGameRecord.developer;
      status = null; // GOV SUSPEND
      register_at = Time.now();
    };

    // Store app data
    gameRecords.put(createGameRecord.game_id, gameRecordNewData);
    #ok(gameRecordNewData);
  };

  public func getAllGameRecord(
    gameRecords : GRT.GameRecordHashMap,
    start : Nat,
    limit : Nat,
  ) : ApiResponse<[GameRecordType]> {
    #ok(Helpers.sliceIter<GameRecordType>(gameRecords.vals(), start, limit));
  };
};
