import Core "../../core/Core";
import HashMap "mo:base/HashMap";
module {

  public type FriendsHashMap = HashMap.HashMap<Text, Friend>;

  public type Friend = {
    user1_principal_id : Core.UserId;
    user2_principal_id : Core.UserId;
    status : Core.Status;
    created_at : Core.Timestamp;
  };
};
