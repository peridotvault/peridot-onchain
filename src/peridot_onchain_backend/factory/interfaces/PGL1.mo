import Principal "mo:base/Principal";
import T "../types/PGL1Types";

module {
  // ---- Aliases yang dibutuhkan tipe interface
  public type Timestamp = T.Timestamp;
  public type Owner = T.Owner;
  public type LicenseId = T.LicenseId;
  public type License = T.License;
  public type Distribution = T.Distribution;
  public type MD = T.Metadata;
  public type V = T.Value;
  public type Result<Ok, Err> = T.Result<Ok, Err>;

  // ---- Definisikan type di LUAR actor type
  public type EventKind = {
    #Burn;
    #Mint;
    #Revoke;
    #SetGovernance;
    #SetPlatform;
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

  // ---- INI yang benar: definisi TYPE interface aktor
  public type Pgl1Interface = actor {
    events_len : query () -> async Nat;
    get_events : query (start : Nat, limit : Nat) -> async [Event];
    licenses_of_owner : query (owner : Owner) -> async [License];
    list_owners : (start : Nat, limit : Nat) -> async [Owner];

    pgl1_game_id : query () -> async Text;
    pgl1_name : query () -> async Text;
    pgl1_description : query () -> async Text;
    pgl1_price : query () -> async ?Nat;
    pgl1_cover_image : query () -> async ?Text;
    pgl1_required_age : query () -> async ?Nat;
    pgl1_banner_image : query () -> async ?Text;
    pgl1_add_distribution : (item : Distribution) -> async Bool;
    pgl1_distribution : query () -> async ?[Distribution];
    pgl1_metadata : query () -> async ?MD;

    pgl1_safeBurn : (of : Owner, reason : ?Text) -> async Result<(), Text>;
    pgl1_safeMint : (to : Owner, expires_at : ?Timestamp) -> async Result<LicenseId, Text>;

    pgl1_set_distribution : (list : [Distribution]) -> async Bool;
    pgl1_set_item_collections : (items : [V]) -> async Bool;
    pgl1_set_platform : (p : Principal) -> async Bool;

    pgl1_total_supply : query () -> async Nat;
    pgl1_website : query () -> async ?Text;
    verify_license : query (owner : Owner) -> async Bool;
  };
};
