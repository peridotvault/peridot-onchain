import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Core "./../../_core_/Core";
import DeveloperTypes "DeveloperTypes";

module {
  // ===== Aliases & Maps =====
  public type UsersHashMap = HashMap.HashMap<Principal, User>;
  public type Username = Text;

  // ===== DTOs =====
  public type CreateUser = {
    username : Username;
    displayName : Text;
    email : Text;
    birthDate : Core.Timestamp;
    gender : Gender;
    country : Core.Country;
  };

  public type UpdateUser = {
    username : Username;
    displayName : Text;
    email : Text;
    imageUrl : ?Text;
    backgroundImageUrl : ?Text;
    userDemographics : UserDemographic;
  };

  // ===== Core Types =====
  public type User = {
    username : Username;
    displayName : Text;
    email : Text;
    imageUrl : ?Text;
    backgroundImageUrl : ?Text;
    totalPlaytime : ?Nat;
    createdAt : Core.Timestamp;
    userDemographics : UserDemographic;
    userInteractions : ?[UserInteraction];
    userLibraries : ?[UserLibrary];
    developer : ?DeveloperTypes.Developer;
  };

  public type UserDemographic = {
    birthDate : Core.Timestamp;
    gender : Gender;
    country : Core.Country;
  };

  public type Gender = { #male; #female; #other };

  public type UserInteraction = {
    appId : Core.AppId;
    interaction : Interaction;
    createdAt : Core.Timestamp;
  };

  public type Interaction = { #view; #purchase; #play };

  public type UserLibrary = {
    appId : Core.AppId;
    playtimeMinute : Nat;
    lastPlayed : ?Core.Timestamp;
    currentVersion : Core.Version;
    createdAt : Core.Timestamp;
  };
};
