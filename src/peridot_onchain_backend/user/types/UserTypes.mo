import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Core "./../../core/Core";
import Developer "./DeveloperTypes";

module {
  public type UsersHashMap = HashMap.HashMap<Principal, User>;

  public type Username = Text;

  public type CreateUser = {
    username : Username;
    display_name : Text;
    email : Text;
    birth_date : Core.Timestamp;
    gender : Gender;
    country : Core.Country;
  };

  public type UpdateUser = {
    username : Username;
    display_name : Text;
    email : Text;
    image_url : ?Text;
    background_image_url : ?Text;
    user_demographics : UserDemographic;
  };

  //  =====================================
  //  =====================================
  // User =================================
  public type User = {
    username : Username;
    display_name : Text;
    email : Text;
    image_url : ?Text;
    background_image_url : ?Text;
    total_playtime : ?Nat;
    created_at : Core.Timestamp;
    user_demographics : UserDemographic;
    user_interactions : ?[UserInteraction];
    user_libraries : ?[UserLibrary];
    developer : ?Developer.Developer;
  };

  // User Demographics =========================
  public type UserDemographic = {
    birth_date : Core.Timestamp;
    gender : Gender;
    country : Core.Country;
  };

  public type Gender = {
    #male;
    #female;
    #other;
  };

  // User Interactions =========================
  public type UserInteraction = {
    app_id : Core.UserId;
    interaction : Interaction;
    created_at : Core.Timestamp;
  };

  public type Interaction = {
    #view;
    #purchase;
    #play;
  };

  // User Library =========================
  public type UserLibrary = {
    app_id : Core.AppId;
    playtime_minute : Nat;
    lastPlayed : ?Core.Timestamp;
    current_version : Core.Version;
    created_at : Core.Timestamp;
  };

  //  =====================================
  //  =====================================
  // User Friends =========================

};
