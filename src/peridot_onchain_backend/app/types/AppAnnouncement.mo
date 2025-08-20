import Core "./../../core/Core";
import HashMap "mo:base/HashMap";

module {

  public type AppAnnouncementHashMap = HashMap.HashMap<Core.DeveloperId, AppAnnouncement>;
  public type AppAnnouncementInteractionHashMap = HashMap.HashMap<Core.AnnouncementId, AppAnnouncementInteraction>;

  // =========================
  // App Announcement
  // =========================
  public type AppAnnouncement = {
    announcementId : Core.AnnouncementId;
    appId : ?Core.AppId; // null => global announcement
    developerId : Core.DeveloperId;
    coverImage : Text;
    headline : Text;
    content : Text;
    pinned : Bool;
    status : Status;
    createdAt : Core.Timestamp;
    updatedAt : ?Core.Timestamp;
    publishAt : ?Core.Timestamp;

  };

  public type AppAnnouncementInteraction = {
    announcementId : Core.AnnouncementId;
    userId : Core.UserId;
    interactionType : InteractionType;
    comment : ?Text;
    createdAt : Core.Timestamp;
  };

  // =========================
  // Status & Reaction
  // =========================
  public type Status = { #draft; #published; #archived };
  public type InteractionType = {
    #like;
    #dislike;
  };
};
