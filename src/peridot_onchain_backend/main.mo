import UserType "./types/User";

import Core "./types/Core";
import UserHandler "handlers/UserHandler";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Int "mo:base/Int";
import User "types/User";
import Developer "types/Developer";

actor Peridot {
  // TYPES ==========================================================
  type User = UserType.User;
  type UserFriend = UserType.UserFriend;
  type ApiResponse<T> = Core.ApiResponse<T>;

  // STATE ==========================================================
  private stable var userEntries : [(Core.UserPrincipal, User)] = [];
  private stable var friendEntries : [(Text, UserType.UserFriend)] = [];
  private stable var announcementEntries : [(Developer.AnnouncementId, Developer.Announcement)] = [];
  private stable var interactionEntries : [(Text, Developer.AnnouncementInteraction)] = [];
  private stable var followEntries : [(Text, Developer.DeveloperFollow)] = [];

  private var users = HashMap.HashMap<Core.UserPrincipal, User>(0, Principal.equal, Principal.hash);
  private var friends = HashMap.HashMap<Text, UserType.UserFriend>(0, Text.equal, Text.hash);
  private var announcements = HashMap.HashMap<Developer.AnnouncementId, Developer.Announcement>(0, Text.equal, Text.hash);
  private var interactions = HashMap.HashMap<Text, Developer.AnnouncementInteraction>(0, Text.equal, Text.hash);
  private var follows = HashMap.HashMap<Text, Developer.DeveloperFollow>(0, Text.equal, Text.hash);

  // HANDLERS =======================================================
  private let userHandler = UserHandler.UserHandler();

  // SYSTEM =========================================================
  system func preupgrade() {
    userEntries := Iter.toArray(users.entries());
    friendEntries := Iter.toArray(friends.entries());
    announcementEntries := Iter.toArray(announcements.entries());
    interactionEntries := Iter.toArray(interactions.entries());
    followEntries := Iter.toArray(follows.entries());
  };

  system func postupgrade() {
    users := HashMap.fromIter<Principal, User>(userEntries.vals(), 1, Principal.equal, Principal.hash);
    friends := HashMap.fromIter<Text, UserType.UserFriend>(friendEntries.vals(), 1, Text.equal, Text.hash);
    announcements := HashMap.fromIter<Developer.AnnouncementId, Developer.Announcement>(announcementEntries.vals(), 1, Text.equal, Text.hash);
    interactions := HashMap.fromIter<Text, Developer.AnnouncementInteraction>(interactionEntries.vals(), 1, Text.equal, Text.hash);
    follows := HashMap.fromIter<Text, Developer.DeveloperFollow>(followEntries.vals(), 1, Text.equal, Text.hash);

    userEntries := [];
    friendEntries := [];
    announcementEntries := [];
    interactionEntries := [];
    followEntries := [];
  };

  //  ===============================================================
  // User ===========================================================
  //  ===============================================================
  // CREATE
  public shared (msg) func createUser(username : User.Username, display_name : Text, email : Text, birth_date : Core.Timestamp, gender : User.Gender, country : Core.Country) : async ApiResponse<User> {

    switch (users.get(msg.caller)) {
      case (?_existing) {
        return #err(#AlreadyExists("This user already exists"));
      };
      case (null) {};
    };

    let user_demographics : User.UserDemographic = {
      birth_date = birth_date;
      gender = gender;
      country = country;
    };

    let user : User = {
      username = username;
      display_name = display_name;
      description = null;
      link = null;
      email = email;
      image_url = null;
      background_image_url = null;
      total_playtime = null;
      created_at = Time.now();
      user_demographics = user_demographics;
      user_interactions = null;
      user_libraries = null;
      developer = null;
    };

    // Validate profile data
    switch (userHandler.validateUsername(user.username)) {
      case (#err(error)) { return #err(#InvalidInput(error)) };
      case (#ok()) {};
    };

    // Check if username already exists
    if (isUsernameTaken(user.username)) {
      return #err(#AlreadyExists("Username already taken"));
    };

    // Store user data
    users.put(msg.caller, user);
    #ok(user);
  };

  // GET
  public shared (msg) func getUserByPrincipalId() : async ApiResponse<User> {
    switch (users.get(msg.caller)) {
      case (null) { #err(#NotFound("User not found")) };
      case (?existing) {
        #ok((existing));
      };
    };
  };

  public query func getUserByUsername(username : Text) : async ApiResponse<User> {
    for ((principal, user) in users.entries()) {
      if (user.username == username) {
        return #ok(user);
      };
    };
    #err(#NotFound("User not found"));
  };

  public query func searchUsersByPrefixWithLimit(prefix : Text, limit : Nat) : async ApiResponse<[User]> {
    if (Text.size(prefix) < 1) {
      return #err(#InvalidInput("Search prefix must not be empty"));
    };
    if (limit < 1) {
      return #err(#InvalidInput("Limit must be greater than 0"));
    };

    let matchingUsers = Buffer.Buffer<User>(0);
    let lowercasePrefix = Text.toLowercase(prefix);

    label searchLoop for ((_, user) in users.entries()) {
      if (matchingUsers.size() >= limit) {
        break searchLoop;
      };

      let lowercaseUsername = Text.toLowercase(user.username);
      if (Text.startsWith(lowercaseUsername, #text lowercasePrefix)) {
        matchingUsers.add(user);
      };
    };

    if (matchingUsers.size() == 0) {
      #err(#NotFound("No users found matching the prefix"));
    } else {
      #ok(Buffer.toArray(matchingUsers));
    };
  };

  // CHEKING
  private func isUsernameTaken(username : Text) : Bool {
    for ((_, user) in users.entries()) {
      if (user.username == username) {
        return true;
      };
    };
    false;
  };

  //  ===============================================================
  // Friend =========================================================
  //  ===============================================================
  // Helper function to generate unique friend ID
  private func generateFriendId(user1 : Principal, user2 : Principal) : Text {
    let sorted = if (Principal.toText(user1) < Principal.toText(user2)) {
      (user1, user2);
    } else { (user2, user1) };
    Principal.toText(sorted.0) # "_" # Principal.toText(sorted.1);
  };

  // Create Friend Request
  public shared (msg) func sendFriendRequest(to_user : Principal) : async ApiResponse<UserFriend> {
    if (Principal.equal(msg.caller, to_user)) {
      return #err(#InvalidInput("Cannot send friend request to yourself"));
    };

    let friendId = generateFriendId(msg.caller, to_user);

    switch (friends.get(friendId)) {
      case (?_existing) {
        return #err(#AlreadyExists("Friend request already exists"));
      };
      case (null) {
        let newFriend : UserType.UserFriend = {
          user1_principal_id = msg.caller;
          user2_principal_id = to_user;
          status = #pending;
          created_at = Time.now();
        };
        friends.put(friendId, newFriend);
        #ok(newFriend);
      };
    };
  };

  // Accept Friend Request
  public shared (msg) func acceptFriendRequest(from_user : Principal) : async ApiResponse<UserFriend> {
    let friendId = generateFriendId(msg.caller, from_user);

    switch (friends.get(friendId)) {
      case (null) {
        return #err(#NotFound("Friend request not found"));
      };
      case (?existing) {
        if (existing.status != #pending) {
          return #err(#InvalidInput("Friend request is not pending"));
        };
        if (Principal.notEqual(msg.caller, existing.user2_principal_id)) {
          return #err(#NotAuthorized("Not authorized to accept this request"));
        };

        let updatedFriend : UserType.UserFriend = {
          user1_principal_id = existing.user1_principal_id;
          user2_principal_id = existing.user2_principal_id;
          status = #accept;
          created_at = existing.created_at;
        };
        friends.put(friendId, updatedFriend);
        #ok(updatedFriend);
      };
    };
  };

  // Get Friend List
  public query (msg) func getFriendList() : async ApiResponse<[UserType.UserFriend]> {
    let userFriends = Buffer.Buffer<UserType.UserFriend>(0);

    for ((_, friend) in friends.entries()) {
      if (
        Principal.equal(msg.caller, friend.user1_principal_id) or
        Principal.equal(msg.caller, friend.user2_principal_id)
      ) {
        userFriends.add(friend);
      };
    };

    if (userFriends.size() == 0) {
      #err(#NotFound("No friends found"));
    } else {
      #ok(Buffer.toArray(userFriends));
    };
  };

  // Remove Friend
  public shared (msg) func removeFriend(friend_principal : Principal) : async ApiResponse<()> {
    let friendId = generateFriendId(msg.caller, friend_principal);

    switch (friends.get(friendId)) {
      case (null) {
        return #err(#NotFound("Friend relationship not found"));
      };
      case (?existing) {
        if (
          Principal.notEqual(msg.caller, existing.user1_principal_id) and
          Principal.notEqual(msg.caller, existing.user2_principal_id)
        ) {
          return #err(#NotAuthorized("Not authorized to remove this friendship"));
        };

        friends.delete(friendId);
        #ok(());
      };
    };
  };

  //  ===============================================================
  // Developer Account Management & Follow ==========================
  //  ===============================================================
  private func generateFollowId(developer : Principal, follower : Principal) : Text {
    Principal.toText(developer) # "_" # Principal.toText(follower);
  };

  // Create Developer Account
  public shared (msg) func createDeveloperProfile(
    website : Text,
    bio : Text,
  ) : async ApiResponse<User> {
    switch (users.get(msg.caller)) {
      case (null) {
        return #err(#NotFound("User not found"));
      };
      case (?existing) {
        let newDeveloper : Developer.Developer = {
          developer_website = website;
          developer_bio = bio;
          total_follower = 0;
          joined_date = Time.now();
          announcements = null;
        };

        let updatedUser : User = {
          existing with
          developer = ?newDeveloper;
        };

        users.put(msg.caller, updatedUser);
        #ok(updatedUser);
      };
    };
  };

  // Get Developer Profile
  public query func getDeveloperProfile(principal_id : Principal) : async ApiResponse<Developer.Developer> {
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

  // Developer Follow Management
  public shared (msg) func followDeveloper(developer_principal : Principal) : async ApiResponse<Developer.DeveloperFollow> {
    if (Principal.equal(msg.caller, developer_principal)) {
      return #err(#InvalidInput("Cannot follow yourself"));
    };

    let followId = generateFollowId(developer_principal, msg.caller);

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
                let newFollow : Developer.DeveloperFollow = {
                  developer_principal_id = developer_principal;
                  follower_principal_id = msg.caller;
                  created_at = Time.now();
                };

                follows.put(followId, newFollow);

                // Update developer's follower count
                let updatedDev : Developer.Developer = {
                  dev with
                  total_follower = dev.total_follower + 1;
                };

                let updatedUser : User = {
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

  // Developer UnFollow Management
  public shared (msg) func unfollowDeveloper(developer_principal : Principal) : async ApiResponse<()> {
    let followId = generateFollowId(developer_principal, msg.caller);

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
                let updatedDev : Developer.Developer = {
                  dev with
                  total_follower = dev.total_follower - 1;
                };

                let updatedUser : User = {
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

  //  ===============================================================
  // Announcement Management ========================================
  //  ===============================================================

  // Helper functions
  private func generateAnnouncementId(developer : Principal, timestamp : Int) : Developer.AnnouncementId {
    Principal.toText(developer) # "_" # Int.toText(timestamp);
  };

  private func generateInteractionId(announcement_id : Developer.AnnouncementId, user : Principal) : Text {
    announcement_id # "_" # Principal.toText(user);
  };

  // Create Announcement
  // Announcement Management
  public shared (msg) func createAnnouncement(
    cover_image : Text,
    headline : Text,
    content : Text,
  ) : async ApiResponse<Developer.Announcement> {
    switch (users.get(msg.caller)) {
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
            let announcement_id = generateAnnouncementId(msg.caller, timestamp);

            let newAnnouncement : Developer.Announcement = {
              id = announcement_id;
              developer_principal_id = msg.caller;
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
            let updatedDev : Developer.Developer = {
              dev with
              announcements = ?Array.append<Developer.AnnouncementId>(currentAnnouncements, [announcement_id]);
            };

            let updatedUser : User = {
              user with
              developer = ?updatedDev;
            };

            users.put(msg.caller, updatedUser);
            #ok(newAnnouncement);
          };
        };
      };
    };
  };

  // Add Comment to Announcement
  // Announcement Interactions
  public shared (msg) func addAnnouncementInteraction(
    announcement_id : Developer.AnnouncementId,
    interaction_type : Developer.InteractionType,
  ) : async ApiResponse<Developer.AnnouncementInteraction> {
    switch (announcements.get(announcement_id)) {
      case (null) {
        return #err(#NotFound("Announcement not found"));
      };
      case (?announcement) {
        let interactionId = generateInteractionId(announcement_id, msg.caller);

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

        let newInteraction : Developer.AnnouncementInteraction = {
          announcement_id = announcement_id;
          user_principal_id = msg.caller;
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

  public shared (msg) func removeAnnouncementInteraction(
    announcement_id : Developer.AnnouncementId
  ) : async ApiResponse<()> {
    let interactionId = generateInteractionId(announcement_id, msg.caller);

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

  // Query functions
  public query func getAnnouncement(announcement_id : Developer.AnnouncementId) : async ApiResponse<Developer.Announcement> {
    switch (announcements.get(announcement_id)) {
      case (null) { #err(#NotFound("Announcement not found")) };
      case (?announcement) { #ok(announcement) };
    };
  };

  public query func getDeveloperAnnouncements(developer_principal : Principal) : async ApiResponse<[Developer.Announcement]> {
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
            let developerAnnouncements = Buffer.Buffer<Developer.Announcement>(0);

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

};
