// Types.mo — PGL-1 Core Types (v1.0.0)
// Gunakan: import T "./Types";

import Principal "mo:base/Principal";
import Time "mo:base/Time";

module PGL1Types {
  public type Timestamp = Time.Time;
  public type GameId = Text; // contoh: "com.peridotvault.vaultbreakers"
  public type Version = Text; // semver: "1.0.3", boleh plus build "+mirror1"
  public type LicenseId = Nat;
  public type Owner = Principal;
  public type Value = {
    #nat : Nat;
    #int : Int;
    #text : Text;
    #blob : Blob;
    #array : [Value];
    #map : [(Text, Value)];
  };
  public type Metadata = [(Text, Value)];

  public type PGLContractMeta = {
    pgl1_game_id : GameId; // "com.peridotvault.vaultbreakers"
    pgl1_cover_image : ?Text; // URL gambar utama (prefer https)
    pgl1_name : Text; // "Vault Breakers"
    pgl1_description : Text; // ringkas (untuk listing)
    pgl1_price : ?Nat; // nominal
    pgl1_required_age : ?Nat; // 17/18/dll
    pgl1_banner_image : ?Text;
    pgl1_metadata : ?Metadata; // pasangan key/value bebas (trait ala NFT)
    pgl1_website : ?Text;
    pgl1_distribution : ?[Distribution];
  };

  public type PGLUpdateMeta = {
    game_id : ?GameId;
    cover_image : ??Text;
    name : ?Text;
    description : ?Text;
    price : ??Nat;
    required_age : ??Nat;
    banner_image : ??Text;
    metadata : ??Metadata;
    website : ??Text;
    distribution : ??[Distribution];
  };

  public type License = {
    id : LicenseId;
    owner : Owner;
    created_at : Timestamp;
    expires_at : ?Timestamp;
    revoked : Bool;
    revoke_reason : ?Text;
  };

  public type Distribution = {
    #web : WebBuild;
    #native : NativeBuild;
  };

  public type WebBuild = {
    url : Text; // ex: https://game.example/play
    processor : Text;
    memory : Nat; // in MB/GB
    storage : Nat; // in MB/GB
    graphics : Text;
    additionalNotes : ?Text;
  };

  public type NativeBuild = {
    os : Text; // windows | macos | linux | Android
    manifests : [Manifest];
    processor : Text;
    memory : Nat; // in MB/GB
    storage : Nat; // in MB/GB
    graphics : Text;
    additionalNotes : ?Text;
  };

  public type Manifest = {
    version : Text; // ex: "1.0.3"
    size_bytes : Nat; // MB/GB
    storageRef : StorageRef; // ganti bucket/basePath/content
    checksum : Text; // integrity (ex: sha256)
    listing : Text; // ringkasan listing (JSON/text) atau pointer
    createdAt : Timestamp;
  };

  public type StorageRef = {
    #s3 : { bucket : Text; basePath : Text };
    #url : { url : Text }; // CDN/HTTP langsung
    #ipfs : { cid : Text; path : ?Text };
  };

  public type EventKind = {
    #Burn;
    #Mint;
    #Revoke;
    #SetGovernance;
    #SetControllers;
    #SetRegistry;
    #UpdateMeta;
  };

  public type Event = {
    idx : Nat;
    kind : EventKind;
    lic : ?LicenseId;
    note : ?Text;
    owner : ?Owner;
    the_actor : Principal;
    time : Timestamp;
  };

  public type Controllers = {
    registry : ?Principal;
    hub : ?Principal;
    developer : ?Principal;
  };

  public type Result<Ok, Err> = { #ok : Ok; #err : Err };

  public type Pgl1Interface = actor {
    // admin
    set_controllers : (args : Controllers) -> async Bool;
    get_controllers : () -> async Controllers;
    pgl1_update_metadata : (args : PGLUpdateMeta) -> async Bool;

    // get
    pgl1_game_id : query () -> async Text;
    pgl1_name : query () -> async Text;
    pgl1_description : query () -> async Text;
    pgl1_price : query () -> async ?Nat;
    pgl1_cover_image : query () -> async ?Text;
    pgl1_required_age : query () -> async ?Nat;
    pgl1_banner_image : query () -> async ?Text;
    pgl1_website : query () -> async ?Text;
    pgl1_metadata : query () -> async ?Metadata;
    pgl1_total_supply : query () -> async Nat;
    pgl1_distribution : query () -> async ?[Distribution];

    // set
    pgl1_safeMint : (to : Owner, expires_at : ?Timestamp) -> async Result<LicenseId, Text>;
    pgl1_safeBurn : (of : Owner, reason : ?Text) -> async Result<(), Text>;
    pgl1_set_distribution : (list : [Distribution]) -> async Bool;
    pgl1_add_distribution : (item : Distribution) -> async Bool;

    verify_license : query (owner : Owner) -> async Bool;
    list_owners : (start : Nat, limit : Nat) -> async [Owner];
    licenses_of_owner : query (owner : Owner) -> async [License];

    events_len : query () -> async Nat;
    get_events : query (start : Nat, limit : Nat) -> async [Event];

    pgl1_set_item_collections : (items : [Value]) -> async Bool;
  };
};
