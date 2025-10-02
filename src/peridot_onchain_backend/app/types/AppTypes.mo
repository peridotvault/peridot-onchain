import Text "mo:base/Text";
import Float "mo:base/Float";
import HashMap "mo:base/HashMap";
import Core "../../core/Core";

module AppTypesModule {
  // Map utama: AppId -> App
  public type AppHashMap = HashMap.HashMap<Core.AppId, App>;
  public type OS = Text; // #windows | #macos | #linux | #android

  // =========================
  // Create DTO
  // =========================
  public type CreateApp = {
    title : Text;
    description : Text;
  };

  public type UpdateApp = {
    title : Text;
    description : Text;
    bannerImage : ?Text;
    coverImage : ?Text;
    previews : ?[Preview];
    price : ?Nat;
    requiredAge : ?Nat;
    releaseDate : ?Core.Timestamp;
    status : Core.AppStatus;
    category : ?[Core.Category];
    appTags : ?[Core.Tag];
    distributions : ?[Distribution];
  };

  // =========================
  // App
  // =========================
  public type App = {
    appId : Core.AppId;
    developerId : Core.DeveloperId;
    title : Text;
    description : Text;
    bannerImage : ?Text;
    coverImage : ?Text;
    previews : ?[Preview];
    price : ?Nat;
    requiredAge : ?Nat;
    releaseDate : ?Core.Timestamp;
    status : Core.AppStatus;
    createdAt : Core.Timestamp;
    category : ?[Core.Category];
    appTags : ?[Core.Tag];
    distributions : ?[Distribution];
    appRatings : ?[AppRating];
  };

  // =========================
  // Preview
  // =========================
  public type Preview = {
    kind : Media;
    url : Text;
  };

  public type Media = {
    #image;
    #video;
  };

  // =========================
  // Distribution (platform)
  // =========================
  public type Distribution = {
    #web : WebBuild;
    #native : NativeBuild;
  };

  public type WebBuild = {
    url : Text; // ex: https://game.example/play
  };

  public type NativeBuild = {
    os : OS; // #windows | #macos | #linux
    manifests : [Manifest];
    processor : Text;
    memory : Nat; // in MB/GB
    storage : Nat; // in MB/GB
    graphics : Text;
    additionalNotes : ?Text;
  };

  // =========================
  // Manifest
  // =========================
  public type Manifest = {
    version : Text; // ex: "1.0.3"
    size : Float; // MB/GB
    bucket : Text; // Storage
    basePath : Text; // folder/path
    checksum : Text; // integrity (ex: sha256)
    content : Text; // payload/listing file
    createdAt : Core.Timestamp;
  };

  // =========================
  // Game Rating
  // =========================
  public type AppRating = {
    userPrincipalId : Core.UserId;
    rating : Nat;
    comment : Text;
    createdAt : Core.Timestamp;
  };

};
