import Core "../../_core_/Core";

module GameTypesModule {
  public type OwnedGame = {
    game_id : Core.GameId;
    canister_id : Principal;
    owned : Bool;
  };

};
