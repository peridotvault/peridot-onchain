import Core "../../_core_/Core";
import HashMap "mo:base/HashMap";

module {

  public type FriendsHashMap = HashMap.HashMap<Text, Friend>;

  public type Friend = {
    user1Id : Core.UserId;
    user2Id : Core.UserId;
    status : Core.Status;
    createdAt : Core.Timestamp;
  };
};
