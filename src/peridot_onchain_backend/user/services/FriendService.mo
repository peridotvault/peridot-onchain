import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Core "../../_core_/Core";
import FriendTypes "../types/FriendTypes";

module {
  type ApiResponse<T> = Core.ApiResponse<T>;
  type FriendType = FriendTypes.Friend;

  // CREATE
  public func createSendFriendRequest(friends : FriendTypes.FriendsHashMap, userId : Core.UserId, to_user : Principal) : ApiResponse<FriendType> {
    if (Principal.equal(userId, to_user)) {
      return #err(#InvalidInput("Cannot send friend request to yourself"));
    };

    let friendId = getFriendId(userId, to_user);

    switch (friends.get(friendId)) {
      case (?_existing) {
        return #err(#AlreadyExists("Friend request already exists"));
      };
      case (null) {
        let newFriend : FriendType = {
          user1Id = userId;
          user2Id = to_user;
          status = #pending;
          createdAt = Time.now();
        };
        friends.put(friendId, newFriend);
        #ok(newFriend);
      };
    };
  };

  // UPDATE
  public func updateAcceptFriendRequest(friends : FriendTypes.FriendsHashMap, userId : Core.UserId, from_user : Principal) : ApiResponse<FriendType> {
    let friendId = getFriendId(userId, from_user);

    switch (friends.get(friendId)) {
      case (null) {
        return #err(#NotFound("Friend request not found"));
      };
      case (?existing) {
        if (existing.status != #pending) {
          return #err(#InvalidInput("Friend request is not pending"));
        };
        if (Principal.notEqual(userId, existing.user2Id)) {
          return #err(#NotAuthorized("Not authorized to accept this request"));
        };

        let updatedFriend : FriendType = {
          user1Id = existing.user1Id;
          user2Id = existing.user2Id;
          status = #accept;
          createdAt = existing.createdAt;
        };
        friends.put(friendId, updatedFriend);
        #ok(updatedFriend);
      };
    };
  };

  // GET
  private func getFriendId(user1 : Principal, user2 : Principal) : Text {
    let sorted = if (Principal.toText(user1) < Principal.toText(user2)) {
      (user1, user2);
    } else { (user2, user1) };
    Principal.toText(sorted.0) # "_" # Principal.toText(sorted.1);
  };

  public func getFriendList(friends : FriendTypes.FriendsHashMap, userId : Core.UserId) : ApiResponse<[FriendType]> {
    let userFriends = Buffer.Buffer<FriendType>(0);

    for ((_, friend) in friends.entries()) {
      if (
        Principal.equal(userId, friend.user1Id) or
        Principal.equal(userId, friend.user2Id)
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

  public func getFriendRequestList(friends : FriendTypes.FriendsHashMap, userId : Core.UserId) : ApiResponse<[FriendType]> {
    let userFriends = Buffer.Buffer<FriendType>(0);

    for ((_, friend) in friends.entries()) {
      if (
        Principal.equal(userId, friend.user1Id) or
        Principal.equal(userId, friend.user2Id) and friend.status == #pending
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

  // DELETE
  public func deleteFriend(friends : FriendTypes.FriendsHashMap, userId : Core.UserId, friend_principal : Principal) : ApiResponse<()> {
    let friendId = getFriendId(userId, friend_principal);

    switch (friends.get(friendId)) {
      case (null) {
        return #err(#NotFound("Friend relationship not found"));
      };
      case (?existing) {
        if (
          Principal.notEqual(userId, existing.user1Id) and
          Principal.notEqual(userId, existing.user2Id)
        ) {
          return #err(#NotAuthorized("Not authorized to remove this friendship"));
        };

        friends.delete(friendId);
        #ok(());
      };
    };
  };
};
