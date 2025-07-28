import Text "mo:base/Text";
import Float "mo:base/Float";
import Core "./../../core/Core";

module App {

  //  =====================================
  //  =====================================
  // App ==================================
  public type App = {
    app_id : Core.AppId;
    developer_principal_id : Core.UserId;
    title : Text;
    description : Text;
    cover_image : Text;
    price : Float;
    required_age : Nat;
    release_date : Core.Timestamp;
    status : Core.Status;
    created_at : Core.Timestamp;
    category : ?Core.Category;
    game_tags : ?[Core.Tag];
    manifests : [Manifest];
    system_requirements : SystemRequirements;
    game_ratings : ?[GameRating];
  };

  // Manifests ============================
  public type Manifest = {
    version : Text;
    size : Float;
    bucket : Text;
    base_path : Text;
    checksum : Text;
    content : Text;
    created_at : Core.Timestamp;
  };

  // System Requirements ==================
  public type SystemRequirements = {
    os : [OS];
    processor : Text;
    memory : Nat;
    storage : Nat;
    graphics : Text;
    additionalNotes : ?Text;
  };

  // OS ===================================
  public type OS = {
    #windows;
    #macos;
    #linux;
    #browser;
  };

  // Game Ratings =========================
  public type GameRating = {
    user_principal_id : Core.UserId;
    rating : Nat;
    comment : Text;
    created_at : Core.Timestamp;
  };

};
