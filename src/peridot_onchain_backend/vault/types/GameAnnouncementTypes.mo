import Core "./../../_core_/Core";
import HashMap "mo:base/HashMap";

module GameAnnouncementTypesModule {

  public type AnnUserKey = { annId : Core.AnnouncementId; userId : Core.UserId };

  public type GameAnnouncementHashMap = HashMap.HashMap<Core.AnnouncementId, GameAnnouncement>;
  public type GameAnnouncementInteractionHashMap = HashMap.HashMap<AnnUserKey, GameAnnouncementInteraction>;

  // =========================
  // DTO
  // =========================
  public type DTOGameAnnouncement = {
    coverImage : Text;
    headline : Text;
    content : Text;
    pinned : Bool;
    status : Status;
  };
  // =========================
  // Game Announcement
  // =========================
  public type GameAnnouncement = {
    announcementId : Core.AnnouncementId;
    gameId : Core.GameId;
    developerId : Core.DeveloperId;
    coverImage : Text;
    headline : Text;
    content : Text;
    pinned : Bool;
    status : Status;
    createdAt : Core.Timestamp;
    updatedAt : ?Core.Timestamp;
  };

  public type GameAnnouncementInteraction = {
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
