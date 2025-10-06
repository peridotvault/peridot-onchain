import UserTypes "types/UserTypes";
import FriendTypes "types/FriendTypes";
import DeveloperTypes "./types/DeveloperTypes";

import UserService "services/UserService";

import Core "./../_core_/Core";

import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import FriendService "services/FriendService";
import DeveloperService "services/DeveloperService";

persistent actor PeridotDirectory {
  // TYPES ==========================================================
  type UserType = UserTypes.User;
  type FriendType = FriendTypes.Friend;
  type DeveloperType = DeveloperTypes.Developer;
  type ApiResponse<T> = Core.ApiResponse<T>;

  // SNAPSHOTS ======================================================
  private var priceUpgradeToDeveloperAccount : Nat = 1_000_000_000;
  private var userEntries : [(Core.UserId, UserType)] = [];
  private var friendEntries : [(Text, FriendType)] = [];
  private var followEntries : [(Text, DeveloperTypes.DeveloperFollow)] = [];

  // STATE ==========================================================
  private transient var users : UserTypes.UsersHashMap = HashMap.HashMap(8, Principal.equal, Principal.hash);
  private transient var friends : FriendTypes.FriendsHashMap = HashMap.HashMap(8, Text.equal, Text.hash);
  private transient var follows : DeveloperTypes.FollowsHashMap = HashMap.HashMap(8, Text.equal, Text.hash);

  // SYSTEM =========================================================
  system func preupgrade() {
    userEntries := Iter.toArray(users.entries());
    friendEntries := Iter.toArray(friends.entries());
    followEntries := Iter.toArray(follows.entries());
  };

  system func postupgrade() {
    users := HashMap.fromIter<Principal, UserType>(userEntries.vals(), 8, Principal.equal, Principal.hash);
    friends := HashMap.fromIter<Text, FriendType>(friendEntries.vals(), 8, Text.equal, Text.hash);
    follows := HashMap.fromIter<Text, DeveloperTypes.DeveloperFollow>(followEntries.vals(), 8, Text.equal, Text.hash);

    userEntries := [];
    friendEntries := [];
    followEntries := [];
  };

  //  ===============================================================
  // User ===========================================================
  //  ===============================================================
  // create
  public shared (msg) func createUser(createUserData : UserTypes.CreateUser) : async ApiResponse<UserType> {
    UserService.createUser(users, msg.caller, createUserData);
  };

  // update
  public shared (msg) func updateUser(updateUserData : UserTypes.UpdateUser) : async ApiResponse<UserType> {
    UserService.updateUser(users, msg.caller, updateUserData);
  };

  // get
  public query func getUserByPrincipalId(userId : Core.UserId) : async ApiResponse<UserType> {
    UserService.getUserByPrincipalId(users, userId);
  };

  public query func getUserByUsername(username : Text) : async ApiResponse<UserType> {
    UserService.getUserByUsername(users, username);
  };

  public shared (msg) func getUserData() : async ApiResponse<UserType> {
    UserService.getUserByPrincipalId(users, msg.caller);
  };

  public query func getUsersByPrefixWithLimit(prefix : Text, limit : Nat) : async ApiResponse<[UserType]> {
    UserService.getUsersByPrefixWithLimit(users, prefix, limit);
  };

  public func getIsUsernameValid(username : Text) : async ApiResponse<Bool> {
    UserService.getIsUsernameValid(users, username);
  };

  //  ===============================================================
  // Friend =========================================================
  //  ===============================================================
  // create
  public shared (msg) func createSendFriendRequest(toUser : Principal) : async ApiResponse<FriendType> {
    FriendService.createSendFriendRequest(friends, msg.caller, toUser);
  };

  // get
  public query (msg) func getFriendList() : async ApiResponse<[FriendType]> {
    FriendService.getFriendList(friends, msg.caller);
  };

  public query (msg) func getFriendRequestList() : async ApiResponse<[FriendType]> {
    FriendService.getFriendRequestList(friends, msg.caller);
  };

  // update
  public shared (msg) func updateAcceptFriendRequest(fromUser : Principal) : async ApiResponse<FriendType> {
    FriendService.updateAcceptFriendRequest(friends, msg.caller, fromUser);
  };

  // delete
  public shared (msg) func deleteFriend(friendPrincipal : Principal) : async ApiResponse<()> {
    FriendService.deleteFriend(friends, msg.caller, friendPrincipal);
  };

  //  ===============================================================
  // Developer ======================================================
  //  ===============================================================
  // create
  public shared (msg) func createDeveloperProfile(website : Text, bio : Text) : async ApiResponse<UserType> {
    let spenderPrincipal = Principal.fromActor(PeridotDirectory);
    let merchant = Principal.fromText(Core.PeridotAccount);
    await DeveloperService.createDeveloperProfile(users, msg.caller, website, bio, Core.TokenLedgerCanister, spenderPrincipal, priceUpgradeToDeveloperAccount, merchant);
  };

  // get
  public query func isUserDeveloper(principalId : Principal) : async Bool {
    DeveloperService.getAmIDeveloper(users, principalId);
  };

  public shared (msg) func getAmIDeveloper() : async Bool {
    DeveloperService.getAmIDeveloper(users, msg.caller);
  };

  public shared query func getDeveloperProfile(principalId : Principal) : async ApiResponse<DeveloperType> {
    DeveloperService.getDeveloperProfile(users, principalId);
  };

  // update
  public shared (msg) func updateFollowDeveloper(developerPrincipal : Principal) : async ApiResponse<DeveloperTypes.DeveloperFollow> {
    DeveloperService.updateFollowDeveloper(users, follows, msg.caller, developerPrincipal);
  };

  public shared (msg) func updateUnfollowDeveloper(developerPrincipal : Principal) : async ApiResponse<()> {
    DeveloperService.updateUnfollowDeveloper(users, follows, msg.caller, developerPrincipal);
  };

  // delete

};
