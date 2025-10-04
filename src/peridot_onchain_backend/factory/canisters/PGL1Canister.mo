import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Hash "mo:base/Hash";

import T "../types/PGL1Types";

/*
  - ✅ list of controller(Registry and Hub)
  - ✅ total minting (total buyer)
  - previews (in metadata)
  - ✅ item address principals (NFT Smart Contract)
  - game_category (in metadata)
  - game_tag (in metadata)
  - ✅ License User (For User Access)
  - ✅ created At
  - ✅ minting (only minting if user don't have Game)
  - ✅ burn (only burn if user have Game)
  - ✅ distribution game manifest build (web, desktop, mobile, etc)
*/

shared ({ caller }) persistent actor class PGL1Canister(initMeta : ?T.PGLContractMeta) = this {
  // ------------ Aliases ------------
  type ContractMeta = T.PGLContractMeta;
  type License = T.License;
  type Result<Ok, Err> = T.Result<Ok, Err>;
  type Owner = T.Owner;
  type LicenseId = T.LicenseId;
  type MD = T.Metadata;
  type V = T.Value;
  type Distribution = T.Distribution;
  type EventKind = T.EventKind;
  type Event = T.Event;

  // ===== Controllers (internal logical roles) =====
  var _owner : Principal = caller; // super-admin (installer)
  var registry_principal : ?Principal = ?caller;
  var hub_principal : ?Principal = null;
  var developer_principal : ?Principal = null;

  private func isOwner(p : Principal) : Bool { Principal.equal(p, _owner) };
  private func isRegistry(p : Principal) : Bool {
    switch (registry_principal) {
      case (null) false;
      case (?x) Principal.equal(p, x);
    };
  };
  private func isHub(p : Principal) : Bool {
    switch (hub_principal) {
      case (null) false;
      case (?x) Principal.equal(p, x);
    };
  };
  private func isDev(p : Principal) : Bool {
    switch (developer_principal) {
      case (null) false;
      case (?x) Principal.equal(p, x);
    };
  };

  // =====================================================================
  // SNAPSHOTS ===========================================================
  // =====================================================================
  private var view : ContractMeta = switch (initMeta) {
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

  // =====================================================================
  // STATE ===============================================================
  // =====================================================================

  // ===== License ledger (per-game) =====
  var licenseOf_owner_entries : [(Owner, LicenseId)] = [];
  var licenseById_entries : [(LicenseId, License)] = [];

  private transient let licenseIdHash = func(id : LicenseId) : Hash.Hash {
    Text.hash(Nat.toText(id));
  };
  private transient var licenseOf_owner = HashMap.HashMap<Owner, LicenseId>(503, Principal.equal, Principal.hash);
  private transient var licenseById = HashMap.HashMap<LicenseId, License>(503, Nat.equal, licenseIdHash);

  // Daftar owner (untuk pagination); burn tidak menghapus dari list, akan difilter saat query
  var owners_index : [Owner] = [];

  // Counter id dan supply
  var next_id : LicenseId = 0;
  var total_supply : Nat = 0;

  // ===== Events (sederhana) =====
  var events : [Event] = [];
  var next_e : Nat = 0;

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

    events := Array.append(events, [e]);
  };

  // =====================================================================
  // SYSTEM ==============================================================
  // =====================================================================
  system func preupgrade() {
    // serialize hashmaps
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
    licenseOf_owner := HashMap.fromIter<Owner, LicenseId>(licenseOf_owner_entries.vals(), 503, Principal.equal, Principal.hash);
    licenseOf_owner_entries := [];

    licenseById := HashMap.fromIter<LicenseId, License>(licenseById_entries.vals(), 503, Nat.equal, licenseIdHash);
    licenseById_entries := [];
  };

  // =====================================================================
  // Controllers =========================================================
  // =====================================================================
  public shared (msg) func set_controllers(args : T.Controllers) : async Bool {
    // Only owner or current registry may rotate controllers
    assert (isOwner(msg.caller) or isRegistry(msg.caller) or isHub(msg.caller));
    registry_principal := args.registry;
    hub_principal := args.hub;
    developer_principal := args.developer;
    emit(
      #SetControllers,
      msg.caller,
      ?(
        "registry=" # (switch (args.registry) { case (null) "-"; case (?r) Principal.toText(r) })
        # "; hub=" # (switch (args.hub) { case (null) "-"; case (?h) Principal.toText(h) })
        # "; dev=" # (switch (args.developer) { case (null) "-"; case (?d) Principal.toText(d) })
      ),
      null,
      null,
    );
    true;
  };

  public query func get_controllers() : async T.Controllers {
    {
      registry = registry_principal;
      hub = hub_principal;
      developer = developer_principal;
    };
  };

  // ===== Admin: bulk update metadata =====
  public shared ({ caller }) func pgl1_update_meta(
    args : T.PGLUpdateMeta
  ) : async Bool {
    let caller_is_registry = isRegistry(caller);
    let caller_is_dev = isDev(caller);
    let caller_is_hub = isHub(caller);

    assert (caller_is_registry or caller_is_dev or caller_is_hub);

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

    switch (args.distribution) {
      case (null) {};
      case (?v) { newView := { newView with pgl1_distribution = v } };
    };

    view := newView;
    emit(#UpdateMeta, caller, null, null, null);
    true;
  };

  //  ===============================================================
  // PGL-1 ==========================================================
  //  ===============================================================

  // GET ======
  public query func pgl1_game_id() : async Text { view.pgl1_game_id };
  public query func pgl1_name() : async Text { view.pgl1_name };
  public query func pgl1_description() : async Text { view.pgl1_description };
  public query func pgl1_price() : async ?Nat { view.pgl1_price };
  public query func pgl1_cover_image() : async ?Text { view.pgl1_cover_image };
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
    if (not isHub(msg.caller)) return #err("FORBIDDEN");

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
    assert (isRegistry(msg.caller) or isHub(msg.caller));
    view := { view with pgl1_distribution = ?list };
    true;
  };

  public shared (msg) func pgl1_add_distribution(item : Distribution) : async Bool {
    assert (isRegistry(msg.caller) or isHub(msg.caller));
    let cur : [Distribution] = switch (view.pgl1_distribution) {
      case (null) [];
      case (?d) d;
    };
    view := { view with pgl1_distribution = ?Array.append(cur, [item]) };
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

  private func textIn(xs : [Text], x : Text) : Bool {
    label s for (t in xs.vals()) { if (t == x) return true };
    false;
  };

  private func md_remove_many(keys : [Text]) {
    if (keys.size() == 0) return;
    let cur = md_cur();
    if (cur.size() == 0) return;
    let buf = Buffer.Buffer<(Text, V)>(cur.size());
    for (kv in cur.vals()) { if (not textIn(keys, kv.0)) { buf.add(kv) } };
    let arr = Buffer.toArray(buf);
    view := { view with pgl1_metadata = if (arr.size() == 0) null else ?arr };
  };

  private func md_upsert_many(kvs : [(Text, V)]) {
    // Use md_set to preserve replace semantics & limits
    for ((k, v) in kvs.vals()) { md_set(k, v) };
  };

  public shared (msg) func pgl1_set_item_collections(items : [V]) : async Bool {
    assert (isRegistry(msg.caller) or isHub(msg.caller));
    md_set("item_collections", #array items);
    true;
  };

  public shared (msg) func pgl1_metadata_upsert(kvs : [(Text, V)]) : async Bool {
    assert (isRegistry(msg.caller) or isHub(msg.caller));
    if (kvs.size() == 0) return true;
    md_upsert_many(kvs);
    emit(#UpdateMeta, msg.caller, ?("md:upsert=" # Nat.toText(kvs.size())), null, null);
    true;
  };

  public shared (msg) func pgl1_metadata_remove(keys : [Text]) : async Bool {
    assert (isRegistry(msg.caller) or isHub(msg.caller));
    if (keys.size() == 0) return true;
    md_remove_many(keys);
    emit(#UpdateMeta, msg.caller, ?("md:remove=" # Nat.toText(keys.size())), null, null);
    true;
  };

  public shared (msg) func pgl1_metadata_update(args : { set : [(Text, V)]; remove : [Text] }) : async Bool {
    assert (isRegistry(msg.caller) or isHub(msg.caller));
    if (args.remove.size() > 0) { md_remove_many(args.remove) };
    if (args.set.size() > 0) { md_upsert_many(args.set) };
    emit(#UpdateMeta, msg.caller, ?("md:update set=" # Nat.toText(args.set.size()) # ", rm=" # Nat.toText(args.remove.size())), null, null);
    true;
  };
};
