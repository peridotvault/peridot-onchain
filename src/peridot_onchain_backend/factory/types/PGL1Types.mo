// Types.mo — PGL-1 Core Types (v1.0.0)
// Gunakan: import T "./Types";

import Principal "mo:base/Principal";
import Time "mo:base/Time";

module PGL1Types {
  // ---------- Versi Standar ----------
  public let STANDARD_NAME : Text = "PGL-1";
  public let STANDARD_VERSION : Text = "1.0.0";

  // ---------- Alias dasar ----------
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

  // ---------- Lisensi non-transferable ----------
  public type License = {
    id : LicenseId;
    owner : Owner;
    created_at : Timestamp;
    expires_at : ?Timestamp;
    revoked : Bool;
    revoke_reason : ?Text;
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

  // =========================
  // Manifest
  // =========================
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

  public type Result<Ok, Err> = { #ok : Ok; #err : Err };

  public type RegistryQuery = actor {
    verify_license : (Owner, GameId) -> async Bool;
    total_supply_of : (GameId) -> async Nat;
    list_owners_of : (GameId, Nat, Nat) -> async [Owner];
    mint_if_absent : (Owner, GameId) -> async Bool;
    burn_if_owned : (Owner, GameId) -> async Bool;
  };
};
