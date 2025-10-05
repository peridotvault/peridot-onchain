import HashMap "mo:base/HashMap";
import Core "./../../_core_/Core";

module PurchaseTypesModule {

  public type PurchaseHashMap = HashMap.HashMap<Core.UserId, [Purchase]>;

  public type Purchase = {
    userId : Core.UserId;
    gameId : Core.GameId;
    amount : Nat;
    purchasedAt : Core.Timestamp;
    txIndex : ?Nat;
    memo : ?Blob;
  };

};
