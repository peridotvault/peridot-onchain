import UserType "./types/User";

import Core "./types/Core";
import UserHandler "handlers/UserHandler";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";
import User "types/User";

actor Peridot {
  // TYPES ==========================================================
  type User = UserType.User;
  type ApiResponse<T> = Core.ApiResponse<T>;

  // STATE ==========================================================
  private stable var userEntries : [(Core.UserPrincipal, User)] = [];
  private var users = HashMap.HashMap<Core.UserPrincipal, User>(0, Principal.equal, Principal.hash);

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
      email = email;
      image_url = null;
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

  // GET ============================================================
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
