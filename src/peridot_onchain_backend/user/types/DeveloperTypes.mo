import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Core "./../../core/Core";

module {
  public type FollowsHashMap = HashMap.HashMap<Text, DeveloperFollow>;

  public type AnnouncementId = Text;
  //  =====================================
  //  =====================================
  // Developer ============================
  public type Developer = {
    developerWebsite : Text;
    developerBio : Text;
    totalFollower : Nat;
    joinedDate : Core.Timestamp;
    announcements : ?[AnnouncementId];
  };

  //  =====================================
  //  =====================================
  // Developer Follower ===================
  public type DeveloperFollow = {
    developerId : Core.UserId;
    followerId : Core.UserId;
    createdAt : Core.Timestamp;
  };
};
