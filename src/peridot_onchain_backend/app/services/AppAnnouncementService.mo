import Core "./../../core/Core";
import AppTypes "../types/AppTypes";
import AppAnnouncementTypes "../types/AppAnnouncementTypes";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Order "mo:base/Order";

module AppAnnouncementServiceModule {
  type ApiResponse<T> = Core.ApiResponse<T>;
  type AppType = AppTypes.App;
  type AppAnnouncementType = AppAnnouncementTypes.AppAnnouncement;
  type AppAnnouncementInteractionType = AppAnnouncementTypes.AppAnnouncementInteraction;

  public func createAnnouncement(
    announcements : AppAnnouncementTypes.AppAnnouncementHashMap,
    apps : AppTypes.AppHashMap,
    appId : Core.AppId,
    developerId : Core.DeveloperId,
    annInput : AppAnnouncementTypes.DTOAppAnnouncement,
    announcementId : Core.AnnouncementId,
  ) : ApiResponse<AppAnnouncementType> {
    // 1) get app existing
    let existingOpt = apps.get(appId);
    switch (existingOpt) {
      case null {
        return #err(#NotFound("App with ID " # Nat.toText(appId) # " not found"));
      };
      case (?app) {
        // 2) otorization: hanya pemilik app yg boleh create Announcement
        if (app.developerId != developerId) {
          return #err(#Unauthorized("Forbidden: you are not the developer of this app"));
        };

        let announcementNewData : AppAnnouncementType = {
          announcementId = announcementId;
          appId = appId;
          developerId = developerId;
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

  public func getAllAnnouncementsByAppId(
    announcements : AppAnnouncementTypes.AppAnnouncementHashMap,
    appId : Core.AppId,
  ) : ApiResponse<[AppAnnouncementType]> {
    // 1) filter by appId
    let filtered = Iter.toArray(
      Iter.filter<AppAnnouncementType>(
        announcements.vals(),
        func(ann : AppAnnouncementType) : Bool { ann.appId == appId },
      )
    );

    // 2) sort: pinned desc, createdAt desc
    let sorted = Array.sort<AppAnnouncementType>(
      filtered,
      func(a : AppAnnouncementType, b : AppAnnouncementType) : Order.Order {
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

  public func updateAnnouncement(
    announcements : AppAnnouncementTypes.AppAnnouncementHashMap,
    developerId : Core.DeveloperId,
    annInput : AppAnnouncementTypes.DTOAppAnnouncement,
    announcementId : Core.AnnouncementId,
  ) : ApiResponse<AppAnnouncementType> {
    // 1) get app existing
    let existingOpt = announcements.get(announcementId);
    switch (existingOpt) {
      case null {
        return #err(#NotFound("Announcement with ID " # Nat.toText(announcementId) # " not found"));
      };
      case (?ann) {
        // 2) otorization: hanya pemilik app yg boleh update Announcement
        if (ann.developerId != developerId) {
          return #err(#Unauthorized("Forbidden: you are not the developer of this App"));
        };

        let announcementUpdateData : AppAnnouncementType = {
          announcementId = announcementId;
          appId = ann.appId;
          developerId = developerId;
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
    announcements : AppAnnouncementTypes.AppAnnouncementHashMap,
    developerId : Core.DeveloperId,
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
        if (ann.developerId != developerId) {
          return #err(#Unauthorized("Forbidden: you are not the developer of this App"));
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
  public func likeByAnnouncementId(announcements : AppAnnouncementTypes.AppAnnouncementHashMap, annInteractions : AppAnnouncementTypes.AppAnnouncementInteractionHashMap, announcementId : Core.AnnouncementId, userId : Core.UserId) : ApiResponse<AppAnnouncementInteractionType> {
    // 1) get app existing
    let existingAnn = announcements.get(announcementId);
    switch (existingAnn) {
      case null {
        return #err(#NotFound("Announcement with ID " # Nat.toText(announcementId) # " not found"));
      };
      case (?ann) {
        // 2) checking interactions
        let annUserKey : AppAnnouncementTypes.AnnUserKey = {
          annId = announcementId;
          userId = userId;
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
        let annInteractionData : AppAnnouncementInteractionType = {
          announcementId = announcementId;
          userId = userId;
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
  public func dislikeByAnnouncementId(announcements : AppAnnouncementTypes.AppAnnouncementHashMap, annInteractions : AppAnnouncementTypes.AppAnnouncementInteractionHashMap, announcementId : Core.AnnouncementId, userId : Core.UserId) : ApiResponse<AppAnnouncementInteractionType> {
    // 1) get app existing
    let existingAnn = announcements.get(announcementId);
    switch (existingAnn) {
      case null {
        return #err(#NotFound("Announcement with ID " # Nat.toText(announcementId) # " not found"));
      };
      case (?ann) {
        // 2) checking interactions
        let annUserKey : AppAnnouncementTypes.AnnUserKey = {
          annId = announcementId;
          userId = userId;
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
        let annInteractionData : AppAnnouncementInteractionType = {
          announcementId = announcementId;
          userId = userId;
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
  public func unLikeDislikeByAnnouncementId(announcements : AppAnnouncementTypes.AppAnnouncementHashMap, annInteractions : AppAnnouncementTypes.AppAnnouncementInteractionHashMap, announcementId : Core.AnnouncementId, userId : Core.UserId) : ApiResponse<AppAnnouncementInteractionType> {
    // 1) get app existing
    let existingAnn = announcements.get(announcementId);
    switch (existingAnn) {
      case null {
        return #err(#NotFound("Announcement with ID " # Nat.toText(announcementId) # " not found"));
      };
      case (?ann) {
        // 2) checking interactions
        let annUserKey : AppAnnouncementTypes.AnnUserKey = {
          annId = announcementId;
          userId = userId;
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
        let annInteractionData : AppAnnouncementInteractionType = {
          announcementId = announcementId;
          userId = userId;
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

  // unLikeDislike
  public func commentByAnnouncementId(announcements : AppAnnouncementTypes.AppAnnouncementHashMap, annInteractions : AppAnnouncementTypes.AppAnnouncementInteractionHashMap, announcementId : Core.AnnouncementId, userId : Core.UserId, comment : Text) : ApiResponse<AppAnnouncementInteractionType> {
    // 1) get app existing
    let existingAnn = announcements.get(announcementId);
    switch (existingAnn) {
      case null {
        return #err(#NotFound("Announcement with ID " # Nat.toText(announcementId) # " not found"));
      };
      case (?ann) {
        // 2) checking interactions
        let annUserKey : AppAnnouncementTypes.AnnUserKey = {
          annId = announcementId;
          userId = userId;
        };
        let existingInteraction = annInteractions.get(annUserKey);
        var interactionType : ?AppAnnouncementTypes.InteractionType = null;
        var createdAt : Core.Timestamp = Time.now();
        switch (existingInteraction) {
          case (null) {};
          case (?annInt) {
            interactionType := annInt.interactionType;
            createdAt := annInt.createdAt;
          };
        };
        let annInteractionData : AppAnnouncementInteractionType = {
          announcementId = announcementId;
          userId = userId;
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
