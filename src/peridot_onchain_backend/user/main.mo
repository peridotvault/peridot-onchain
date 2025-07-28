import UserTypes "types/UserTypes";
import FriendTypes "types/FriendTypes";
import DeveloperTypes "./types/DeveloperTypes";

import UserService "services/UserService";

import Core "./../core/Core";

import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import FriendService "services/FriendService";
import DeveloperService "services/DeveloperService";

persistent actor Peridot {
  // TYPES ==========================================================
  type UserType = UserTypes.User;
  type FriendType = FriendTypes.Friend;
  type DeveloperType = DeveloperTypes.Developer;
  type ApiResponse<T> = Core.ApiResponse<T>;

  // STATE ==========================================================
  private var userEntries : [(Core.UserId, UserType)] = [];
  private var friendEntries : [(Text, FriendType)] = [];
  private var announcementEntries : [(DeveloperTypes.AnnouncementId, DeveloperTypes.Announcement)] = [];
  private var interactionEntries : [(Text, DeveloperTypes.AnnouncementInteraction)] = [];
  private var followEntries : [(Text, DeveloperTypes.DeveloperFollow)] = [];

  private transient var users : UserTypes.UsersHashMap = HashMap.HashMap(0, Principal.equal, Principal.hash);
  private transient var friends : FriendTypes.FriendsHashMap = HashMap.HashMap(0, Text.equal, Text.hash);
  private transient var follows : DeveloperTypes.FollowsHashMap = HashMap.HashMap(0, Text.equal, Text.hash);
  private transient var announcements : DeveloperTypes.AnnouncementsHashMap = HashMap.HashMap(0, Text.equal, Text.hash);

  private transient var interactions : DeveloperTypes.InteractionsHashMap = HashMap.HashMap(0, Text.equal, Text.hash);

  // SYSTEM =========================================================
  system func preupgrade() {
    userEntries := Iter.toArray(users.entries());
    friendEntries := Iter.toArray(friends.entries());
    announcementEntries := Iter.toArray(announcements.entries());
    interactionEntries := Iter.toArray(interactions.entries());
    followEntries := Iter.toArray(follows.entries());
  };

  system func postupgrade() {
    users := HashMap.fromIter<Principal, UserType>(userEntries.vals(), 1, Principal.equal, Principal.hash);
    friends := HashMap.fromIter<Text, FriendType>(friendEntries.vals(), 1, Text.equal, Text.hash);
    announcements := HashMap.fromIter<DeveloperTypes.AnnouncementId, DeveloperTypes.Announcement>(announcementEntries.vals(), 1, Text.equal, Text.hash);
    interactions := HashMap.fromIter<Text, DeveloperTypes.AnnouncementInteraction>(interactionEntries.vals(), 1, Text.equal, Text.hash);
    follows := HashMap.fromIter<Text, DeveloperTypes.DeveloperFollow>(followEntries.vals(), 1, Text.equal, Text.hash);

    userEntries := [];
    friendEntries := [];
    announcementEntries := [];
    interactionEntries := [];
    followEntries := [];
  };

  //  ===============================================================
  // User ===========================================================
  //  ===============================================================
  // create
  public shared (msg) func createUser(createUserData : UserTypes.CreateUser) : async ApiResponse<UserType> {
    return UserService.createUser(users, msg.caller, createUserData);
  };

  // update
  public shared (msg) func updateUser(updateUserData : UserTypes.UpdateUser) : async ApiResponse<UserType> {
    return UserService.updateUser(users, msg.caller, updateUserData)

  };

  // get
  public shared (msg) func getUserByPrincipalId() : async ApiResponse<UserType> {
    return UserService.getUserByPrincipalId(users, msg.caller);
  };

  public query func getUserByUsername(username : Text) : async ApiResponse<UserType> {
    return UserService.getUserByUsername(users, username);
  };

  public query func getUsersByPrefixWithLimit(prefix : Text, limit : Nat) : async ApiResponse<[UserType]> {
    return UserService.getUsersByPrefixWithLimit(users, prefix, limit);
  };

  public func getIsUsernameValid(username : Text) : async ApiResponse<Bool> {
    return UserService.getIsUsernameValid(users, username);
  };

  //  ===============================================================
  // Friend =========================================================
  //  ===============================================================
  // create
  public shared (msg) func createSendFriendRequest(to_user : Principal) : async ApiResponse<FriendType> {
    return FriendService.createSendFriendRequest(friends, msg.caller, to_user);

  };

  // update
  public shared (msg) func updateAcceptFriendRequest(from_user : Principal) : async ApiResponse<FriendType> {
    return FriendService.updateAcceptFriendRequest(friends, msg.caller, from_user);

  };

  // get
  public query (msg) func getFriendList() : async ApiResponse<[FriendType]> {
    return FriendService.getFriendList(friends, msg.caller);
  };

  public query (msg) func getFriendRequestList() : async ApiResponse<[FriendType]> {
    return FriendService.getFriendRequestList(friends, msg.caller);
  };

  // delete
  public shared (msg) func deleteFriend(friend_principal : Principal) : async ApiResponse<()> {
    return FriendService.deleteFriend(friends, msg.caller, friend_principal);

  };

  //  ===============================================================
  // Developer ======================================================
  //  ===============================================================
  // create
  public shared (msg) func createDeveloperProfile(website : Text, bio : Text) : async ApiResponse<UserType> {
    return DeveloperService.createDeveloperProfile(users, msg.caller, website, bio);
  };

  public shared (msg) func createFollowDeveloper(developer_principal : Principal) : async ApiResponse<DeveloperTypes.DeveloperFollow> {
    return DeveloperService.createFollowDeveloper(users, follows, msg.caller, developer_principal);
  };

  public shared (msg) func createAnnouncement(cover_image : Text, headline : Text, content : Text) : async ApiResponse<DeveloperTypes.Announcement> {
    return DeveloperService.createAnnouncement(users, announcements, msg.caller, cover_image, headline, content);
  };

  public shared (msg) func createAnnouncementInteraction(
    announcement_id : DeveloperTypes.AnnouncementId,
    interaction_type : DeveloperTypes.InteractionType,
  ) : async ApiResponse<DeveloperTypes.AnnouncementInteraction> {
    return DeveloperService.createAnnouncementInteraction(announcements, interactions, msg.caller, announcement_id, interaction_type);
  };

  // get
  public query func getDeveloperProfile(principal_id : Principal) : async ApiResponse<DeveloperType> {
    return DeveloperService.getDeveloperProfile(users, principal_id);
  };

  public query func getAnnouncement(announcement_id : DeveloperTypes.AnnouncementId) : async ApiResponse<DeveloperTypes.Announcement> {
    return DeveloperService.getAnnouncement(announcements, announcement_id);
  };

  public query func getDeveloperAnnouncements(developer_principal : Principal) : async ApiResponse<[DeveloperTypes.Announcement]> {
    return DeveloperService.getDeveloperAnnouncements(users, announcements, developer_principal);
  };

  // update
  public shared (msg) func updateUnfollowDeveloper(developer_principal : Principal) : async ApiResponse<()> {
    return DeveloperService.updateUnfollowDeveloper(users, follows, msg.caller, developer_principal);

  };

  // delete
  public shared (msg) func deleteAnnouncementInteraction(
    announcement_id : DeveloperTypes.AnnouncementId
  ) : async ApiResponse<()> {
    return DeveloperService.deleteAnnouncementInteraction(announcements, interactions, msg.caller, announcement_id);

  };

};
