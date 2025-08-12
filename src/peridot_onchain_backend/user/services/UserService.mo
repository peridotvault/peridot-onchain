import UserTypes "../types/UserTypes";
import Core "../../core/Core";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import UserHandler "../handlers/UserHandler";

module {
  type ApiResponse<T> = Core.ApiResponse<T>;
  type UserType = UserTypes.User;

  // CREATE
  public func createUser(
    users : UserTypes.UsersHashMap,
    userId : Core.UserId,
    createUserData : UserTypes.CreateUser,
  ) : ApiResponse<UserType> {
    switch (users.get(userId)) {
      case (?_) { return #err(#AlreadyExists("This user already exists")) };
      case (null) {};
    };

    // validate username
    switch (UserHandler.UserHandler().validateUsername(createUserData.username)) {
      case (#err(error)) { return #err(#InvalidInput(error)) };
      case (#ok()) {};
    };
    if (getIsUsernameTaken(users, createUserData.username)) {
      return #err(#AlreadyExists("Username already taken"));
    };

    let userDemographics : UserTypes.UserDemographic = {
      birthDate = createUserData.birthDate;
      gender = createUserData.gender;
      country = createUserData.country;
    };

    let userNewData : UserType = {
      username = createUserData.username;
      displayName = createUserData.displayName;
      email = createUserData.email;
      imageUrl = null;
      backgroundImageUrl = null;
      totalPlaytime = null;
      createdAt = Time.now();
      userDemographics = userDemographics;
      userInteractions = null;
      userLibraries = null;
      developer = null;
    };

    users.put(userId, userNewData);
    #ok(userNewData);
  };

  // UPDATE
  public func updateUser(
    users : UserTypes.UsersHashMap,
    userId : Core.UserId,
    updateUserData : UserTypes.UpdateUser,
  ) : ApiResponse<UserType> {
    switch (users.get(userId)) {
      case (null) {
        return #err(#NotFound("User not found, You Need to Create Account"));
      };
      case (?existing) {
        // username check jika berubah
        if (updateUserData.username != existing.username) {
          if (getIsUsernameTaken(users, updateUserData.username)) {
            return #err(#AlreadyExists("Username already taken"));
          };
        };

        // validate username
        switch (UserHandler.UserHandler().validateUsername(updateUserData.username)) {
          case (#err(error)) { return #err(#InvalidInput(error)) };
          case (#ok()) {};
        };

        let newUpdatedUser : UserType = {
          existing with
          username = updateUserData.username;
          displayName = updateUserData.displayName;
          email = updateUserData.email;
          imageUrl = updateUserData.imageUrl;
          backgroundImageUrl = updateUserData.backgroundImageUrl;
          userDemographics = updateUserData.userDemographics;
        };

        users.put(userId, newUpdatedUser);
        #ok(newUpdatedUser);
      };
    };
  };

  // GET
  public func getUserByPrincipalId(
    users : UserTypes.UsersHashMap,
    userId : Core.UserId,
  ) : ApiResponse<UserType> {
    switch (users.get(userId)) {
      case (null) { #err(#NotFound("User not found")) };
      case (?existing) { #ok(existing) };
    };
  };

  public func getUserByUsername(
    users : UserTypes.UsersHashMap,
    username : Text,
  ) : ApiResponse<UserType> {
    for ((_, user) in users.entries()) {
      if (user.username == username) { return #ok(user) };
    };
    #err(#NotFound("User not found"));
  };

  private func getIsUsernameTaken(
    users : UserTypes.UsersHashMap,
    username : Text,
  ) : Bool {
    for ((_, user) in users.entries()) {
      if (user.username == username) { return true };
    };
    false;
  };

  public func getUsersByPrefixWithLimit(
    users : UserTypes.UsersHashMap,
    prefix : Text,
    limit : Nat,
  ) : ApiResponse<[UserType]> {
    if (Text.size(prefix) < 1) {
      return #err(#InvalidInput("Search prefix must not be empty"));
    };
    if (limit < 1) {
      return #err(#InvalidInput("Limit must be greater than 0"));
    };

    let matchingUsers = Buffer.Buffer<UserType>(0);
    let lowercasePrefix = Text.toLowercase(prefix);

    label searchLoop for ((_, user) in users.entries()) {
      if (matchingUsers.size() >= limit) { break searchLoop };

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

  public func getIsUsernameValid(
    users : UserTypes.UsersHashMap,
    username : Text,
  ) : ApiResponse<Bool> {
    if (getIsUsernameTaken(users, username)) {
      return #err(#InvalidInput("username already taken"));
    };
    switch (UserHandler.UserHandler().validateUsername(username)) {
      case (#err(error)) { return #err(#InvalidInput(error)) };
      case (#ok()) { return #ok(true) };
    };
  };
};
