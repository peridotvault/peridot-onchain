import UserType "./types/User";

import Core "./types/Core";
import UserHandler "handlers/UserHandler";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";

actor Peridot {
  // TYPES ==========================================================
  type User = UserType.User;
  type ApiResponse<T> = Core.ApiResponse<T>;

  // STATE ==========================================================
  private stable var userEntries : [(Principal, User)] = [];
  private var users = HashMap.HashMap<Principal, User>(0, Principal.equal, Principal.hash);

  // HANDLERS =======================================================
  private let userHandler = UserHandler.UserHandler();

  // SYSTEM =========================================================
  system func preupgrade() {
    userEntries := Iter.toArray(users.entries());
  };

  system func postupgrade() {
    users := HashMap.fromIter<Principal, User>(
      userEntries.vals(),
      1,
      Principal.equal,
      Principal.hash,
    );
    userEntries := [];
  };

  // CREATE =========================================================
  public shared (msg) func createUser(user : User) : async ApiResponse<User> {

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

  // GET ============================================================
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

  // CHEKING ========================================================
  private func isUsernameTaken(username : Text) : Bool {
    for ((_, user) in users.entries()) {
      if (user.username == username) {
        return true;
      };
    };
    false;
  };

};
