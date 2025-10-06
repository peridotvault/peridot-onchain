import PeridotRegistry "canister:peridot_registry";

import Core "./../../_core_/Core";
import GameAnnouncementTypes "../types/GameAnnouncementTypes";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Order "mo:base/Order";
import Principal "mo:base/Principal";

module GameAnnouncementServiceModule {
  type ApiResponse<T> = Core.ApiResponse<T>;
  type GameAnnouncementType = GameAnnouncementTypes.GameAnnouncement;
  type GameAnnouncementInteractionType = GameAnnouncementTypes.GameAnnouncementInteraction;

  public func createAnnouncement(
    announcements : GameAnnouncementTypes.GameAnnouncementHashMap,
    gameId : Core.GameId,
    caller : Principal,
    annInput : GameAnnouncementTypes.DTOGameAnnouncement,
    announcementId : Core.AnnouncementId,
  ) : async ApiResponse<GameAnnouncementType> {
    // 1) get app existing
    let isExist = await PeridotRegistry.getGameRecordById(gameId);
    switch (isExist) {
      case (#err err) {
        return #err(err);
      };
      case (#ok game) {
        // 2) otorization: hanya pemilik app yg boleh create Announcement
        if (game.developer != caller) {
          return #err(#Unauthorized("Forbidden: you are not the developer of this game"));
        };

        let announcementNewData : GameAnnouncementType = {
          announcementId = announcementId;
          gameId = gameId;
          developerId = game.developer;
          coverImage = annInput.coverImage;
          headline = annInput.headline;
          content = annInput.content;
          pinned = annInput.pinned;
          status = annInput.status;
          createdAt = Time.now();
          updatedAt = null;
        };

        // 3) create announcement
        announcements.put(announcementId, announcementNewData);
        return #ok(announcementNewData);
      };
    };
  };

  public func getAllAnnouncementsByGameId(
    announcements : GameAnnouncementTypes.GameAnnouncementHashMap,
    gameId : Core.GameId,
  ) : ApiResponse<[GameAnnouncementType]> {
    // 1) filter by appId
    let filtered = Iter.toArray(
      Iter.filter<GameAnnouncementType>(
        announcements.vals(),
        func(ann : GameAnnouncementType) : Bool { ann.gameId == gameId },
      )
    );

    // 2) sort: pinned desc, createdAt desc
    let sorted = Array.sort<GameAnnouncementType>(
      filtered,
      func(a : GameAnnouncementType, b : GameAnnouncementType) : Order.Order {
        if (a.pinned != b.pinned) {
          // pinned true harus muncul dulu
          if (a.pinned) { #less } else { #greater };
        } else if (a.createdAt > b.createdAt) {
          #less;
        } else if (a.createdAt < b.createdAt) {
          #greater;
        } else {
          #equal;
        };
      },
    );

    #ok(sorted);
  };

  public func getAnnouncementsByAnnouncementId(
    announcements : GameAnnouncementTypes.GameAnnouncementHashMap,
    announcementId : Core.AnnouncementId,
  ) : ApiResponse<GameAnnouncementType> {
    let existingOpt = announcements.get(announcementId);
    switch (existingOpt) {
      case (null) {
        return #err(#NotFound("Announcement with ID " # Nat.toText(announcementId) # " not found"));
      };
      case (?announcement) {
        return #ok(announcement);
      };
    };
  };

  public func updateAnnouncement(
    announcements : GameAnnouncementTypes.GameAnnouncementHashMap,
    caller : Principal,
    annInput : GameAnnouncementTypes.DTOGameAnnouncement,
    announcementId : Core.AnnouncementId,
  ) : ApiResponse<GameAnnouncementType> {
    // 1) get app existing
    let existingOpt = announcements.get(announcementId);
    switch (existingOpt) {
      case null {
        return #err(#NotFound("Announcement with ID " # Nat.toText(announcementId) # " not found"));
      };
      case (?ann) {
        // 2) otorization: hanya pemilik app yg boleh update Announcement
        if (ann.developerId != caller) {
          return #err(#Unauthorized("Forbidden: you are not the developer of this Game"));
        };

        let announcementUpdateData : GameAnnouncementType = {
          announcementId = announcementId;
          gameId = ann.gameId;
          developerId = caller;
          coverImage = annInput.coverImage;
          headline = annInput.headline;
          content = annInput.content;
          pinned = annInput.pinned;
          status = annInput.status;
          createdAt = ann.createdAt;
          updatedAt = ?Time.now();
        };

        // 3) update announcement
        announcements.put(announcementId, announcementUpdateData);
        return #ok(announcementUpdateData);
      };
    };

  };

  public func deleteAnnouncement(
    announcements : GameAnnouncementTypes.GameAnnouncementHashMap,
    caller : Principal,
    announcementId : Core.AnnouncementId,
  ) : ApiResponse<Text> {
    // 1) get app existing
    let existingOpt = announcements.get(announcementId);
    switch (existingOpt) {
      case null {
        return #err(#NotFound("Announcement with ID " # Nat.toText(announcementId) # " not found"));
      };
      case (?ann) {
        // 2) otorization: hanya pemilik app yg boleh delete Announcement
        if (ann.developerId != caller) {
          return #err(#Unauthorized("Forbidden: you are not the developer of this Game"));
        };

        // 3) delete announcement
        announcements.delete(announcementId);
        return #ok("Delete Announcement Successfully");
      };
    };
  };

  //  ===============================================================
  // Announcement Interactions ======================================
  //  ===============================================================
  // like
  public func likeByAnnouncementId(announcements : GameAnnouncementTypes.GameAnnouncementHashMap, annInteractions : GameAnnouncementTypes.GameAnnouncementInteractionHashMap, announcementId : Core.AnnouncementId, caller : Principal) : ApiResponse<GameAnnouncementInteractionType> {
    // 1) get app existing
    let existingAnn = announcements.get(announcementId);
    switch (existingAnn) {
      case null {
        return #err(#NotFound("Announcement with ID " # Nat.toText(announcementId) # " not found"));
      };
      case (?ann) {
        // 2) checking interactions
        let annUserKey : GameAnnouncementTypes.AnnUserKey = {
          annId = announcementId;
          userId = caller;
        };
        let existingInteraction = annInteractions.get(annUserKey);
        var oldComment : ?Text = null;
        var createdAt : Core.Timestamp = Time.now();
        switch (existingInteraction) {
          case (null) {};
          case (?annInt) {
            oldComment := annInt.comment;
            createdAt := annInt.createdAt;
          };
        };
        let annInteractionData : GameAnnouncementInteractionType = {
          announcementId = announcementId;
          userId = caller;
          interactionType = ?#like;
          comment = oldComment;
          createdAt = createdAt;
        };

        // 3) update announcement
        annInteractions.put(annUserKey, annInteractionData);
        return #ok(annInteractionData);
      };
    };
  };

  // dislike
  public func dislikeByAnnouncementId(announcements : GameAnnouncementTypes.GameAnnouncementHashMap, annInteractions : GameAnnouncementTypes.GameAnnouncementInteractionHashMap, announcementId : Core.AnnouncementId, caller : Principal) : ApiResponse<GameAnnouncementInteractionType> {
    // 1) get app existing
    let existingAnn = announcements.get(announcementId);
    switch (existingAnn) {
      case null {
        return #err(#NotFound("Announcement with ID " # Nat.toText(announcementId) # " not found"));
      };
      case (?ann) {
        // 2) checking interactions
        let annUserKey : GameAnnouncementTypes.AnnUserKey = {
          annId = announcementId;
          userId = caller;
        };
        let existingInteraction = annInteractions.get(annUserKey);
        var oldComment : ?Text = null;
        var createdAt : Core.Timestamp = Time.now();
        switch (existingInteraction) {
          case (null) {};
          case (?annInt) {
            oldComment := annInt.comment;
            createdAt := annInt.createdAt;
          };
        };
        let annInteractionData : GameAnnouncementInteractionType = {
          announcementId = announcementId;
          userId = caller;
          interactionType = ?#dislike;
          comment = oldComment;
          createdAt = createdAt;
        };

        // 3) update announcement
        annInteractions.put(annUserKey, annInteractionData);
        return #ok(annInteractionData);
      };
    };
  };

  // unLikeDislike
  public func unLikeDislikeByAnnouncementId(announcements : GameAnnouncementTypes.GameAnnouncementHashMap, annInteractions : GameAnnouncementTypes.GameAnnouncementInteractionHashMap, announcementId : Core.AnnouncementId, caller : Principal) : ApiResponse<GameAnnouncementInteractionType> {
    // 1) get ann existing
    let existingAnn = announcements.get(announcementId);
    switch (existingAnn) {
      case null {
        return #err(#NotFound("Announcement with ID " # Nat.toText(announcementId) # " not found"));
      };
      case (?ann) {
        // 2) checking interactions
        let annUserKey : GameAnnouncementTypes.AnnUserKey = {
          annId = announcementId;
          userId = caller;
        };
        let existingInteraction = annInteractions.get(annUserKey);
        var oldComment : ?Text = null;
        var createdAt : Core.Timestamp = Time.now();
        switch (existingInteraction) {
          case (null) {};
          case (?annInt) {
            oldComment := annInt.comment;
            createdAt := annInt.createdAt;
          };
        };
        let annInteractionData : GameAnnouncementInteractionType = {
          announcementId = announcementId;
          userId = caller;
          interactionType = null;
          comment = oldComment;
          createdAt = createdAt;
        };

        // 3) update announcement
        annInteractions.put(annUserKey, annInteractionData);
        return #ok(annInteractionData);
      };
    };
  };

  // commentByAnnouncementId
  public func commentByAnnouncementId(announcements : GameAnnouncementTypes.GameAnnouncementHashMap, annInteractions : GameAnnouncementTypes.GameAnnouncementInteractionHashMap, announcementId : Core.AnnouncementId, caller : Principal, comment : Text) : ApiResponse<GameAnnouncementInteractionType> {
    // 1) get app existing
    let existingAnn = announcements.get(announcementId);
    switch (existingAnn) {
      case null {
        return #err(#NotFound("Announcement with ID " # Nat.toText(announcementId) # " not found"));
      };
      case (?ann) {
        // 2) checking interactions
        let annUserKey : GameAnnouncementTypes.AnnUserKey = {
          annId = announcementId;
          userId = caller;
        };
        let existingInteraction = annInteractions.get(annUserKey);
        var interactionType : ?GameAnnouncementTypes.InteractionType = null;
        var createdAt : Core.Timestamp = Time.now();
        switch (existingInteraction) {
          case (null) {};
          case (?annInt) {
            interactionType := annInt.interactionType;
            createdAt := annInt.createdAt;
          };
        };
        let annInteractionData : GameAnnouncementInteractionType = {
          announcementId = announcementId;
          userId = caller;
          interactionType = interactionType;
          comment = ?comment;
          createdAt = createdAt;
        };

        // 3) update announcement
        annInteractions.put(annUserKey, annInteractionData);
        return #ok(annInteractionData);
      };
    };
  };

};
