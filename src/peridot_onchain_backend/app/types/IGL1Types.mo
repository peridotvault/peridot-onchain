// Types.mo
import Principal "mo:base/Principal";

module {
  public type Timestamp = Nat64;
  public type GameId = Text;
  public type Version = Text;
  public type LicenseId = Nat;

  // ============ ROLES ============
  public type Role = {
    #Platform; // Peridot (pemilik registry)
    #Publisher; // Developer yang diotorisasi oleh Platform
    #Unknown; // Bukan keduanya
  };

  // ============ LICENSE ============
  public type License = {
    id : LicenseId;
    game_id : GameId;
    owner : Principal;
    created_at : Timestamp;
    expires_at : ?Timestamp;
    entitlements : [Text];
    metadata_uri : ?Text;
    revocable : Bool;
    revoked : Bool;
    revoke_reason : ?Text;
  };

  public type MintOpts = {
    expires_at : ?Timestamp;
    entitlements : ?[Text];
    metadata_uri : ?Text;
    revocable : ?Bool;
  };

  // ============ RELEASE ============
  public type ReleaseRef = {
    game_id : GameId;
    version : Version;
  };

  public type ReleaseState = {
    #Proposed;
    #Approved;
    #Published;
    #Deprecated;
    #Withdrawn;
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
    manifest_hash : ?Text; // opsional: simpan hash dari manifest JSON
  };

  // ============ EVENTS ============
  public type EventKind = {
    #Mint;
    #Revoke;
    #Burn;
    #Expire;
    #ProposeRelease;
    #ApproveRelease;
    #PublishRelease;
    #DeprecateRelease;
    #WithdrawRelease;
  };

  public type Event = {
    idx : Nat;
    time : Timestamp;
    kind : EventKind;
    game_id : ?GameId;
    license_id : ?LicenseId;
    _actor : Principal;
    note : ?Text;
  };

  public type PageArgs = { start : Nat; limit : Nat };

  // ============ PURCHASE (opsional hook) ============
  public type PurchaseRequest = {
    game_id : GameId;
    buyer : Principal;
    payment_asset : Text; // "ICP" | "PER" | dst
    payment_amount : Nat;
    referral_code : ?Text;
  };

  public type PurchaseResult = {
    #ok : { license_id : LicenseId; owner : Principal };
    #err : {
      #AlreadyOwned;
      #NotForSale;
      #InvalidPrice;
      #PaymentFailed;
      #Unauthorized;
      #ExpiredOffer;
    };
  };
};
