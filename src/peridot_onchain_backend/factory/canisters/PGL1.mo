import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Hash "mo:base/Hash";

import T "../types/PGL1Types";

// Regular actor (not actor class) - this will be deployed once
shared ({ caller }) persistent actor class PGL1(initMeta : ?T.PGLContractMeta) = this {
  // ------------ Aliases ------------
  type Meta = T.PGLContractMeta;
  type License = T.License;
  type Result<Ok, Err> = T.Result<Ok, Err>;
  type Owner = T.Owner;
  type LicenseId = T.LicenseId;
  type MD = T.Metadata;
  type V = T.Value;
  type Distribution = T.Distribution;

  type EventKind = {
    #Mint;
    #Burn;
    #Revoke;
    #SetPlatform;
    #SetGovernance;
    #UpdateMeta;
  };

  type Event = {
    idx : Nat;
    time : T.Timestamp;
    kind : EventKind;
    the_actor : Principal;
    note : ?Text;
    owner : ?Owner;
    lic : ?LicenseId;
  };

  // SNAPSHOTS ======================================================
  private var view : Meta = switch (initMeta) {
    case (null) {
      {
        pgl1_game_id = "com.peridotvault.vaultbreakers";
        pgl1_cover_image = ?"https://...";
        pgl1_name = "PeridotVault Game";
        pgl1_description = "PeridotVault Description";
        pgl1_price = ?0;
        pgl1_required_age = ?12;
        pgl1_banner_image = null;
        pgl1_website = null;
        pgl1_metadata = null;
        pgl1_distribution = null;
      };
    };
    case (?meta) meta;
  };

  // STATE ==========================================================
  private var platform_principal : ?Principal = ?caller;

  private func isPlatform(p : Principal) : Bool = switch (platform_principal) {
    case (null) false;
    case (?plat) Principal.equal(p, plat);
  };

  // ===== License ledger (per-game) =====
  private var licenseOf_owner_entries : [(Owner, LicenseId)] = [];
  private var licenseById_entries : [(LicenseId, License)] = [];

  private transient let licenseIdHash = func(id : LicenseId) : Hash.Hash {
    Text.hash(Nat.toText(id));
  };

  private transient var licenseOf_owner = HashMap.HashMap<Owner, LicenseId>(503, Principal.equal, Principal.hash);
  private transient var licenseById = HashMap.HashMap<LicenseId, License>(503, Nat.equal, licenseIdHash);

  // Daftar owner (untuk pagination); burn tidak menghapus dari list, akan difilter saat query
  private var owners_index : [Owner] = [];

  // Counter id dan supply
  private var next_id : LicenseId = 0;
  private var total_supply : Nat = 0;

  // ===== Events (sederhana) =====
  private var events : [Event] = [];
  private var next_e : Nat = 0;

  private func now() : T.Timestamp = Time.now();

  private func emit(kind : EventKind, the_actor : Principal, note : ?Text, owner : ?Owner, lic : ?LicenseId) {
    let e : Event = {
      idx = next_e;
      time = now();
      kind;
      the_actor;
      note;
      owner;
      lic;
    };
    next_e += 1;
    let buf = Buffer.Buffer<Event>(events.size() + 1);
    for (x in events.vals()) { buf.add(x) };
    buf.add(e);
    events := Buffer.toArray(buf);
  };

  // SYSTEM =========================================================
  system func preupgrade() {
    licenseOf_owner_entries := [];
    for ((k, v) in licenseOf_owner.entries()) {
      licenseOf_owner_entries := Array.append(licenseOf_owner_entries, [(k, v)]);
    };

    licenseById_entries := [];
    for ((k, v) in licenseById.entries()) {
      licenseById_entries := Array.append(licenseById_entries, [(k, v)]);
    };
  };

  system func postupgrade() {
    licenseOf_owner := HashMap.fromIter<Owner, LicenseId>(
      licenseOf_owner_entries.vals(),
      503,
      Principal.equal,
      Principal.hash,
    );
    licenseOf_owner_entries := [];

    licenseById := HashMap.fromIter<LicenseId, License>(
      licenseById_entries.vals(),
      503,
      Nat.equal,
      licenseIdHash,
    );
    licenseById_entries := [];
  };

  // ===== Admin: set principals =====
  public shared (msg) func pgl1_set_platform(p : Principal) : async Bool {
    platform_principal := ?p;
    emit(#SetPlatform, msg.caller, ?("platform=" # Principal.toText(p)), null, null);
    true;
  };

  // ===== Admin: bulk update metadata =====
  public shared (msg) func pgl1_admin_update(
    args : {
      game_id : ?Text;
      name : ?Text;
      description : ?Text;
      cover_image : ??Text;
      price : ??Nat;
      required_age : ??Nat;
      metadata : ??MD;
      banner_image : ??Text;
      website : ??Text;
    }
  ) : async Bool {
    assert (isPlatform(msg.caller));

    var newView = view;

    switch (args.game_id) {
      case (null) {};
      case (?v) { newView := { newView with pgl1_game_id = v } };
    };

    switch (args.name) {
      case (null) {};
      case (?v) { newView := { newView with pgl1_name = v } };
    };

    switch (args.description) {
      case (null) {};
      case (?v) { newView := { newView with pgl1_description = v } };
    };

    switch (args.cover_image) {
      case (null) {};
      case (?v) { newView := { newView with pgl1_cover_image = v } };
    };

    switch (args.price) {
      case (null) {};
      case (?v) { newView := { newView with pgl1_price = v } };
    };

    switch (args.required_age) {
      case (null) {};
      case (?v) { newView := { newView with pgl1_required_age = v } };
    };

    switch (args.metadata) {
      case (null) {};
      case (?v) { newView := { newView with pgl1_metadata = v } };
    };

    switch (args.banner_image) {
      case (null) {};
      case (?v) { newView := { newView with pgl1_banner_image = v } };
    };

    switch (args.website) {
      case (null) {};
      case (?v) { newView := { newView with pgl1_website = v } };
    };

    view := newView;
    emit(#UpdateMeta, msg.caller, null, null, null);
    true;
  };

  //  ===============================================================
  // PGL-1 ==========================================================
  //  ===============================================================

  // GET ======
  public query func pgl1_game_id() : async Text { view.pgl1_game_id };
  public query func pgl1_cover_image() : async ?Text { view.pgl1_cover_image };
  public query func pgl1_name() : async Text { view.pgl1_name };
  public query func pgl1_description() : async Text { view.pgl1_description };
  public query func pgl1_price() : async ?Nat { view.pgl1_price };
  public query func pgl1_required_age() : async ?Nat { view.pgl1_required_age };
  public query func pgl1_banner_image() : async ?Text { view.pgl1_banner_image };
  public query func pgl1_website() : async ?Text { view.pgl1_website };
  public query func pgl1_metadata() : async ?MD { view.pgl1_metadata };
  public query func pgl1_total_supply() : async Nat { total_supply };
  public query func pgl1_distribution() : async ?[Distribution] {
    view.pgl1_distribution;
  };

  // SET ======
  public shared (msg) func pgl1_safeMint(to : Owner, expires_at : ?T.Timestamp) : async Result<LicenseId, Text> {
    if (not isPlatform(msg.caller)) return #err("FORBIDDEN");
    switch (licenseOf_owner.get(to)) {
      case (?existing) {
        switch (licenseById.get(existing)) {
          case (?lic) {
            if (lic.revoked == false) return #ok(existing);
          };
          case (null) {};
        };
      };
      case (null) {};
    };
    let id : LicenseId = next_id;
    next_id += 1;

    let lic : License = {
      id = id;
      owner = to;
      created_at = now();
      expires_at = expires_at;
      revoked = false;
      revoke_reason = null;
    };
    licenseById.put(id, lic);
    licenseOf_owner.put(to, id);
    owners_index := Array.append(owners_index, [to]);
    total_supply += 1;

    emit(#Mint, msg.caller, null, ?to, ?id);
    #ok(id);
  };

  public shared (msg) func pgl1_safeBurn(of : Owner, reason : ?Text) : async Result<(), Text> {
    if (not (isPlatform(msg.caller))) return #err("FORBIDDEN");
    switch (licenseOf_owner.get(of)) {
      case (null) { #err("NOT_OWNED") };
      case (?id) {
        switch (licenseById.get(id)) {
          case (null) { #err("INTERNAL_MISSING") };
          case (?lic) {
            if (lic.revoked) return #ok(());
            let upd : License = {
              lic with revoked = true;
              revoke_reason = reason;
            };
            licenseById.put(id, upd);
            if (total_supply > 0) { total_supply -= 1 };
            emit(#Burn, msg.caller, reason, ?of, ?id);
            #ok(());
          };
        };
      };
    };
  };

  public shared (msg) func pgl1_set_distribution(list : [Distribution]) : async Bool {
    assert (isPlatform(msg.caller));
    view := { view with pgl1_distribution = ?list };
    true;
  };

  public query func verify_license(owner : Owner) : async Bool {
    switch (licenseOf_owner.get(owner)) {
      case (null) false;
      case (?id) {
        switch (licenseById.get(id)) {
          case (null) false;
          case (?lic) {
            if (lic.revoked) return false;
            switch (lic.expires_at) {
              case (null) true;
              case (?t) { now() <= t };
            };
          };
        };
      };
    };
  };

  public shared func list_owners(start : Nat, limit : Nat) : async [Owner] {
    if (limit == 0) return [];
    var out = Buffer.Buffer<Owner>(limit);
    var i : Nat = 0;
    var taken : Nat = 0;
    label scan for (o in owners_index.vals()) {
      if (i < start) { i += 1; continue scan };
      if (taken >= limit) break scan;
      if (await verify_license(o)) {
        out.add(o);
        taken += 1;
      };
      i += 1;
    };
    Buffer.toArray(out);
  };

  public query func licenses_of_owner(owner : Owner) : async [License] {
    switch (licenseOf_owner.get(owner)) {
      case (null) [];
      case (?id) {
        switch (licenseById.get(id)) { case (null) []; case (?lic) [lic] };
      };
    };
  };

  public shared (msg) func pgl1_add_distribution(item : Distribution) : async Bool {
    assert (isPlatform(msg.caller));
    let cur : [Distribution] = switch (view.pgl1_distribution) {
      case (null) [];
      case (?d) d;
    };
    view := { view with pgl1_distribution = ?Array.append(cur, [item]) };
    true;
  };

  // ===== Events (audit) =====
  public query func events_len() : async Nat { events.size() };
  public query func get_events(start : Nat, limit : Nat) : async [Event] {
    if (limit == 0 or start >= events.size()) return [];
    let end = Nat.min(start + limit, events.size());
    Array.tabulate<Event>(end - start, func i { events[start + i] });
  };

  private func md_cur() : MD {
    switch (view.pgl1_metadata) { case (null) []; case (?m) m };
  };

  private func md_set(key : Text, val : V) {
    let cur : MD = md_cur();
    var replaced = false;

    let out = Array.map<(Text, V), (Text, V)>(
      cur,
      func(kv) {
        if (kv.0 == key) { replaced := true; (key, val) } else kv;
      },
    );
    let newMeta : MD = if (replaced) out else Array.append(out, [(key, val)]);
    view := { view with pgl1_metadata = ?newMeta };
  };

  public shared (msg) func pgl1_set_item_collections(items : [V]) : async Bool {
    assert (isPlatform(msg.caller));
    md_set("item_collections", #array items);
    true;
  };
};
