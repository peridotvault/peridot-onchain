// Types.mo — IGL-1 Core Types (v1.0.0)
// Gunakan: import T "./Types";

import Principal "mo:base/Principal";

module PGL1Types {
  // ---------- Versi Standar ----------
  public let STANDARD_NAME : Text = "IGL-1";
  public let STANDARD_VERSION : Text = "1.0.0";

  // ---------- Alias dasar ----------
  public type Timestamp = Nat64;
  public type GameId = Text; // contoh: "com.peridotvault.vaultbreakers"
  public type Version = Text; // semver: "1.0.3", boleh plus build "+mirror1"
  public type LicenseId = Nat;
  public type Owner = Principal;
  public type Metadata = [Value];
  public type Value = {
    #nat : Nat;
    #int : Int;
    #text : Text;
    #blob : Blob;
  };

  // ---------- Hasil (Result) util ----------
  public type Result<Ok, Err> = {
    #ok : Ok;
    #err : Err;
  };

  // ---------- Peran/Roles ----------
  public type Role = {
    #Platform; // pemilik registry (Peridot)
    #Publisher; // developer yang diotorisasi Platform
    #Governance; // entitas DAO/governance principal
    #Unknown;
  };

  // ---------- Governance ----------
  public type GovReasonCode = {
    #ILLEGAL_GAMBLING;
    #SEX_EXPLICIT;
    #HATE;
    #MALWARE;
    #FAKE_PUBLISHER;
    #OTHER;
  };

  // ---------- Lisensi non-transferable ----------
  public type License = {
    id : LicenseId;
    game_id : GameId;
    owner : Owner;
    created_at : Timestamp;
    expires_at : ?Timestamp;
    entitlements : [Text]; // "base-game", "dlc:pack1", dst.
    metadata_uri : ?Text; // pointer metadata opsional (JSON/HTTP/IPFS)
    revocable : Bool; // boleh direvoke oleh Platform/Gov?
    revoked : Bool;
    revoke_reason : ?Text;
  };

  public type MintOpts = {
    expires_at : ?Timestamp;
    entitlements : ?[Text];
    metadata_uri : ?Text;
    revocable : ?Bool; // default true
  };

  // ---------- Rilis (Release) & Status ----------
  public type ReleaseRef = { game_id : GameId; version : Version };

  public type ReleaseState = {
    #Proposed; // diajukan publisher
    #Approved; // di-approve Platform
    #Published; // tayang (immutable)
    #Deprecated; // tidak disarankan, masih tersedia untuk kompatibilitas
    #Suspended; // di-suspend (manifest/keys tidak dilayani)
    #Withdrawn; // ditarik (takedown)
  };

  public type Release = {
    ref : ReleaseRef;
    state : ReleaseState;
    created_at : Timestamp;
    created_by : Principal;
    approved_at : ?Timestamp;
    approved_by : ?Principal;
    published_at : ?Timestamp;
    published_by : ?Principal;
    deprecated_at : ?Timestamp;
    deprecated_by : ?Principal;
    deprecate_reason : ?Text;
    suspended_at : ?Timestamp;
    suspended_by : ?Principal;
    suspend_reason : ?{ code : GovReasonCode; note : ?Text };
    withdrawn_at : ?Timestamp;
    withdrawn_by : ?Principal;
    withdraw_reason : ?{ code : GovReasonCode; note : ?Text };
    manifest_hash : ?Text; // hash dari JSON manifest (opsional, untuk audit cepat)
  };

  // ---------- Manifest konten (content-addressed) ----------
  // Catatan: Manifest biasanya diserialisasi ke JSON dan disimpan/diambil utuh sebagai Text.
  // Tipe di bawah berguna jika kamu ingin membangun/validasi manifest di dalam canister.
  public type Locator = {
    #s3 : { url : Text }; // https://… atau s3://…
    #http : { url : Text }; // HTTP/HTTPS murni (CDN)
    #other : { url : Text }; // link share
  };

  public type EncInfo = {
    alg : Text; // "AES-GCM"
    iv : Text; // base64/hex
    tag : ?Text; // base64/hex (opsional jika digabung)
  };

  public type Chunk = {
    path : Text; // relative path di paket
    index : Nat; // urutan chunk
    size : Nat; // byte
    sha256 : Text; // hex/base64; boleh BLAKE3 jika kamu pakai "hash":"blake3"
    hashAlg : ?Text; // "sha256" (default) | "blake3"
    locators : [Locator]; // daftar sumber download
    enc : ?EncInfo; // info enkripsi jika DRM ringan aktif
  };

  public type ReleaseManifest = {
    standard : Text; // "IGL-1-release"
    game_id : GameId;
    version : Version;
    created_at : Timestamp;
    total_size : Nat;
    chunks : [Chunk];
    meta : ?{
      // opsional: info tambahan
      platforms : ?[Text]; // ["win","mac","linux"]
      min_launcher : ?Text; // versi minimal launcher
      notes : ?Text;
    };
  };

  // ---------- Event & Audit ----------
  public type EventKind = {
    // Lisensi
    #Mint;
    #Revoke;
    #Burn;
    #Expire;

    // Rilis
    #ProposeRelease;
    #ApproveRelease;
    #PublishRelease;
    #DeprecateRelease;

    // Governance
    #GovBanPublisher;
    #GovUnbanPublisher;
    #GovSuspend;
    #GovUnsuspend;
    #GovWithdraw;
    #GovRevoke;
  };

  public type Event = {
    idx : Nat;
    time : Timestamp;
    kind : EventKind;
    the_actor : Principal; // pemanggil/otoritas yang mengeksekusi
    game_id : ?GameId;
    license_id : ?LicenseId;
    version : ?Version;
    reason : ?{ code : GovReasonCode; note : ?Text };
    note : ?Text;
  };

  public type PageArgs = { start : Nat; limit : Nat };

  // ---------- Purchase (opsional hook di Store) ----------
  public type PurchaseRequest = {
    game_id : GameId;
    buyer : Owner;
    payment_asset : Text; // "ICP" | "PER" | "ETH" | "SOL" | dll
    payment_amount : Nat;
    referral_code : ?Text;
  };

  public type PurchaseError = {
    #AlreadyOwned;
    #NotForSale;
    #InvalidPrice;
    #PaymentFailed;
    #Unauthorized;
    #ExpiredOffer;
  };

  public type PurchaseResult = {
    #ok : { license_id : LicenseId; owner : Owner };
    #err : PurchaseError;
  };

  // ---------- Error umum (opsional) ----------
  public type StdError = {
    #NotFound;
    #AlreadyExists;
    #Forbidden;
    #InvalidState;
    #BadArgs;
    #Internal;
  };
};
