import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Core "../../_core_/Core";

module GameRecordTypes {
  public type GameRecordHashMap = HashMap.HashMap<Core.GameId, GameRecord>;

  public type GameRecord = {
    game_id : Core.GameId;
    canister_id : Principal;
    developer : Core.Developer;
    status : ?Text; // GOV SUSPEND
    register_at : Core.Timestamp;
  };

  // DTO
  public type CreateGameRecord = {
    canister_id : Principal;
    developer : Core.Developer;
  };

};
