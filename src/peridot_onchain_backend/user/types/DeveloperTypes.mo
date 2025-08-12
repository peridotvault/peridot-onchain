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

// public type AnnouncementsHashMap = HashMap.HashMap<Text, Announcement>;
// public type InteractionsHashMap = HashMap.HashMap<Text, AnnouncementInteraction>;

//  =====================================
//  =====================================
// Announcements ==============
// public type Announcement = {
//   id : AnnouncementId;
//   developerId : Core.UserId;
//   coverImage : Text;
//   headline : Text;
//   content : Text;
//   totalLikes : Nat;
//   totalDislikes : Nat;
//   createdAt : Core.Timestamp;
// };

// Separated interaction records
// public type AnnouncementInteraction = {
//   announcementId : AnnouncementId;
//   userId : Core.UserId;
//   interactionType : InteractionType;
//   createdAt : Core.Timestamp;
// };

// public type InteractionType = {
//   #like;
//   #dislike;
//   #comment : Text;
// };

// // Announcement Comment =================
// public type AnnouncementComment = {
//     userId : Core.UserId;
//     comment : Text;
//     createdAt : Core.Timestamp;
// };

// // Announcement Like ====================
// public type AnnouncementLike = {
//     userId : Core.UserId;
// };

// // Announcement Dislike =================
// public type AnnouncementDislike = {
//     userId : Core.UserId;
// };
