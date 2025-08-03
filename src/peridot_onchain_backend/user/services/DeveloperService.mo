import UserTypes "../types/UserTypes";
import DeveloperTypes "../types/DeveloperTypes";

import Core "../../core/Core";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Int "mo:base/Int";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";

module {
  type ApiResponse<T> = Core.ApiResponse<T>;
  type UserType = UserTypes.User;
  type DeveloperType = DeveloperTypes.Developer;

  // create
  public func createDeveloperProfile(users : UserTypes.UsersHashMap, userId : Core.UserId, website : Text, bio : Text) : ApiResponse<UserType> {
    switch (users.get(userId)) {
      case (null) {
        return #err(#NotFound("User not found"));
      };
      case (?existing) {
        let newDeveloper : DeveloperType = {
          developer_website = website;
          developer_bio = bio;
          total_follower = 0;
          joined_date = Time.now();
          announcements = null;
        };

        let updatedUser : UserType = {
          existing with
          developer = ?newDeveloper;
        };

        users.put(userId, updatedUser);
        #ok(updatedUser);
      };
    };
  };

  public func createFollowDeveloper(users : UserTypes.UsersHashMap, follows : DeveloperTypes.FollowsHashMap, userId : Core.UserId, developer_principal : Principal) : ApiResponse<DeveloperTypes.DeveloperFollow> {
    if (Principal.equal(userId, developer_principal)) {
      return #err(#InvalidInput("Cannot follow yourself"));
    };

    let followId = getFollowId(developer_principal, userId);

    switch (follows.get(followId)) {
      case (?_) {
        return #err(#AlreadyExists("Already following this developer"));
      };
      case (null) {
        switch (users.get(developer_principal)) {
          case (null) {
            return #err(#NotFound("Developer not found"));
          };
          case (?user) {
            switch (user.developer) {
              case (null) {
                return #err(#NotFound("Developer profile not found"));
              };
              case (?dev) {
                let newFollow : DeveloperTypes.DeveloperFollow = {
                  developer_principal_id = developer_principal;
                  follower_principal_id = userId;
                  created_at = Time.now();
                };

                follows.put(followId, newFollow);

                // Update developer's follower count
                let updatedDev : DeveloperType = {
                  dev with
                  total_follower = dev.total_follower + 1;
                };

                let updatedUser : UserType = {
                  user with
                  developer = ?updatedDev;
                };

                users.put(developer_principal, updatedUser);
                #ok(newFollow);
              };
            };
          };
        };
      };
    };
  };

  public func createAnnouncement(users : UserTypes.UsersHashMap, announcements : DeveloperTypes.AnnouncementsHashMap, userId : Core.UserId, cover_image : Text, headline : Text, content : Text) : ApiResponse<DeveloperTypes.Announcement> {
    switch (users.get(userId)) {
      case (null) {
        return #err(#NotFound("User not found"));
      };
      case (?user) {
        switch (user.developer) {
          case (null) {
            return #err(#NotFound("Developer profile not found"));
          };
          case (?dev) {
            let timestamp = Time.now();
            let announcement_id = generateAnnouncementId(userId, timestamp);

            let newAnnouncement : DeveloperTypes.Announcement = {
              id = announcement_id;
              developer_principal_id = userId;
              cover_image = cover_image;
              headline = headline;
              content = content;
              total_likes = 0;
              total_dislikes = 0;
              created_at = timestamp;
            };

            announcements.put(announcement_id, newAnnouncement);

            // Properly handle optional announcements array
            let currentAnnouncements = switch (dev.announcements) {
              case (null) { [] };
              case (?arr) { arr };
            };

            // Update developer's announcements list
            let updatedDev : DeveloperTypes.Developer = {
              dev with
              announcements = ?Array.append<DeveloperTypes.AnnouncementId>(currentAnnouncements, [announcement_id]);
            };

            let updatedUser : UserType = {
              user with
              developer = ?updatedDev;
            };

            users.put(userId, updatedUser);
            #ok(newAnnouncement);
          };
        };
      };
    };
  };

  public func createAnnouncementInteraction(announcements : DeveloperTypes.AnnouncementsHashMap, interactions : DeveloperTypes.InteractionsHashMap, userId : Core.UserId, announcement_id : DeveloperTypes.AnnouncementId, interaction_type : DeveloperTypes.InteractionType) : ApiResponse<DeveloperTypes.AnnouncementInteraction> {
    switch (announcements.get(announcement_id)) {
      case (null) {
        return #err(#NotFound("Announcement not found"));
      };
      case (?announcement) {
        let interactionId = generateInteractionId(announcement_id, userId);

        // Remove any existing interaction
        switch (interactions.get(interactionId)) {
          case (?existing) {
            // Update counts based on previous interaction
            let updatedAnnouncement = switch (existing.interaction_type) {
              case (#like) {
                { announcement with total_likes = announcement.total_likes - 1 };
              };
              case (#dislike) {
                {
                  announcement with total_dislikes = announcement.total_dislikes - 1
                };
              };
              case (#comment(_)) { announcement };
            };
            announcements.put(announcement_id, updatedAnnouncement);
          };
          case (null) {};
        };

        let newInteraction : DeveloperTypes.AnnouncementInteraction = {
          announcement_id = announcement_id;
          user_principal_id = userId;
          interaction_type = interaction_type;
          created_at = Time.now();
        };

        // Update announcement counts
        let finalAnnouncement = switch (interaction_type) {
          case (#like) {
            { announcement with total_likes = announcement.total_likes + 1 };
          };
          case (#dislike) {
            {
              announcement with total_dislikes = announcement.total_dislikes + 1
            };
          };
          case (#comment(_)) { announcement };
        };

        interactions.put(interactionId, newInteraction);
        announcements.put(announcement_id, finalAnnouncement);
        #ok(newInteraction);
      };
    };
  };

  //   update
  public func updateUnfollowDeveloper(users : UserTypes.UsersHashMap, follows : DeveloperTypes.FollowsHashMap, userId : Core.UserId, developer_principal : Principal) : ApiResponse<()> {
    let followId = getFollowId(developer_principal, userId);

    switch (follows.get(followId)) {
      case (null) {
        return #err(#NotFound("Not following this developer"));
      };
      case (?_) {
        switch (users.get(developer_principal)) {
          case (null) {
            return #err(#NotFound("Developer not found"));
          };
          case (?user) {
            switch (user.developer) {
              case (null) {
                return #err(#NotFound("Developer profile not found"));
              };
              case (?dev) {
                follows.delete(followId);

                // Update developer's follower count
                let updatedDev : DeveloperTypes.Developer = {
                  dev with
                  total_follower = dev.total_follower - 1;
                };

                let updatedUser : UserType = {
                  user with
                  developer = ?updatedDev;
                };

                users.put(developer_principal, updatedUser);
                #ok(());
              };
            };
          };
        };
      };
    };
  };

  // get
  public func getDeveloperProfile(users : UserTypes.UsersHashMap, principal_id : Principal) : ApiResponse<DeveloperType> {
    switch (users.get(principal_id)) {
      case (null) {
        return #err(#NotFound("User not found"));
      };
      case (?user) {
        switch (user.developer) {
          case (null) {
            return #err(#NotFound("Developer profile not found"));
          };
          case (?dev) {
            #ok(dev);
          };
        };
      };
    };
  };

  public func getDeveloperAnnouncements(users : UserTypes.UsersHashMap, announcements : DeveloperTypes.AnnouncementsHashMap, developer_principal : Principal) : ApiResponse<[DeveloperTypes.Announcement]> {
    switch (users.get(developer_principal)) {
      case (null) {
        return #err(#NotFound("Developer not found"));
      };
      case (?user) {
        switch (user.developer) {
          case (null) {
            return #err(#NotFound("Developer profile not found"));
          };
          case (?dev) {
            let developerAnnouncements = Buffer.Buffer<DeveloperTypes.Announcement>(0);

            // Properly handle optional announcements array
            switch (dev.announcements) {
              case (null) {
                return #ok([]);
              };
              case (?announcementIds) {
                for (announcement_id in announcementIds.vals()) {
                  switch (announcements.get(announcement_id)) {
                    case (?announcement) {
                      developerAnnouncements.add(announcement);
                    };
                    case (null) {};
                  };
                };
              };
            };
            #ok(Buffer.toArray(developerAnnouncements));
          };
        };
      };
    };
  };

  public func getAnnouncement(announcements : DeveloperTypes.AnnouncementsHashMap, announcement_id : DeveloperTypes.AnnouncementId) : ApiResponse<DeveloperTypes.Announcement> {
    switch (announcements.get(announcement_id)) {
      case (null) { #err(#NotFound("Announcement not found")) };
      case (?announcement) { #ok(announcement) };
    };
  };

  private func getFollowId(developer : Principal, follower : Principal) : Text {
    return Principal.toText(developer) # "_" # Principal.toText(follower);
  };

  private func generateAnnouncementId(developer : Principal, timestamp : Int) : DeveloperTypes.AnnouncementId {
    Principal.toText(developer) # "_" # Int.toText(timestamp);
  };

  private func generateInteractionId(announcement_id : DeveloperTypes.AnnouncementId, user : Principal) : Text {
    announcement_id # "_" # Principal.toText(user);
  };

  //   delete
  public func deleteAnnouncementInteraction(announcements : DeveloperTypes.AnnouncementsHashMap, interactions : DeveloperTypes.InteractionsHashMap, userId : Core.UserId, announcement_id : DeveloperTypes.AnnouncementId) : ApiResponse<()> {
    let interactionId = generateInteractionId(announcement_id, userId);

    switch (interactions.get(interactionId)) {
      case (null) {
        return #err(#NotFound("No interaction found"));
      };
      case (?interaction) {
        switch (announcements.get(announcement_id)) {
          case (null) {
            return #err(#NotFound("Announcement not found"));
          };
          case (?announcement) {
            // Update counts based on removed interaction
            let updatedAnnouncement = switch (interaction.interaction_type) {
              case (#like) {
                { announcement with total_likes = announcement.total_likes - 1 };
              };
              case (#dislike) {
                {
                  announcement with total_dislikes = announcement.total_dislikes - 1
                };
              };
              case (#comment(_)) { announcement };
            };

            interactions.delete(interactionId);
            announcements.put(announcement_id, updatedAnnouncement);
            #ok(());
          };
        };
      };
    };
  };

};
