import Core "./../../core/Core";
import HashMap "mo:base/HashMap";

module AppAnnouncementTypesModule {

  public type AnnUserKey = { annId : Core.AnnouncementId; userId : Core.UserId };

  public type AppAnnouncementHashMap = HashMap.HashMap<Core.AnnouncementId, AppAnnouncement>;
  public type AppAnnouncementInteractionHashMap = HashMap.HashMap<AnnUserKey, AppAnnouncementInteraction>;

  // =========================
  // DTO
  // =========================
  public type DTOAppAnnouncement = {
    coverImage : Text;
    headline : Text;
    content : Text;
    pinned : Bool;
    status : Status;
  };
  // =========================
  // App Announcement
  // =========================
  public type AppAnnouncement = {
    announcementId : Core.AnnouncementId;
    appId : Core.AppId;
    developerId : Core.DeveloperId;
    coverImage : Text;
    headline : Text;
    content : Text;
    pinned : Bool;
    status : Status;
    createdAt : Core.Timestamp;
    updatedAt : ?Core.Timestamp;
  };

  public type AppAnnouncementInteraction = {
    announcementId : Core.AnnouncementId;
    userId : Core.UserId;
    interactionType : ?InteractionType;
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
