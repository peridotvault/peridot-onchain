import HashMap "mo:base/HashMap";
import Core "./../../core/Core";

module PurchaseTypesModule {

  public type PurchaseHashMap = HashMap.HashMap<Core.UserId, [Purchase]>;

  public type Purchase = {
    userId : Core.UserId;
    appId : Core.AppId;
    amount : Nat;
    purchasedAt : Core.Timestamp;
    txIndex : ?Nat;
    memo : ?Blob;
  };

};
