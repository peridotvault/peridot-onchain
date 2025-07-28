import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Core "./../../core/Core";

module {
  public type FollowsHashMap = HashMap.HashMap<Text, DeveloperFollow>;
  public type AnnouncementsHashMap = HashMap.HashMap<Text, Announcement>;
  public type InteractionsHashMap = HashMap.HashMap<Text, AnnouncementInteraction>;

  public type AnnouncementId = Text;
  //  =====================================
  //  =====================================
  // Developer ============================
  public type Developer = {
    developer_website : Text;
    developer_bio : Text;
    total_follower : Nat;
    joined_date : Core.Timestamp;
    announcements : ?[AnnouncementId];
  };

  //  =====================================
  //  =====================================
  // Developer Follower ===================
  public type DeveloperFollow = {
    developer_principal_id : Core.UserId;
    follower_principal_id : Core.UserId;
    created_at : Core.Timestamp;
  };

  //  =====================================
  //  =====================================
  // Announcements ==============
  public type Announcement = {
    id : AnnouncementId;
    developer_principal_id : Core.UserId;
    cover_image : Text;
    headline : Text;
    content : Text;
    total_likes : Nat;
    total_dislikes : Nat;
    created_at : Core.Timestamp;
  };

  // Separated interaction records
  public type AnnouncementInteraction = {
    announcement_id : AnnouncementId;
    user_principal_id : Core.UserId;
    interaction_type : InteractionType;
    created_at : Core.Timestamp;
  };

  public type InteractionType = {
    #like;
    #dislike;
    #comment : Text;
  };

  // // Announcement Comment =================
  // public type AnnouncementComment = {
  //     user_principal_id : Core.UserId;
  //     comment : Text;
  //     created_at : Core.Timestamp;
  // };

  // // Announcement Like ====================
  // public type AnnouncementLike = {
  //     user_principal_id : Core.UserId;
  // };

  // // Announcement Dislike =================
  // public type AnnouncementDislike = {
  //     user_principal_id : Core.UserId;
  // };
};
