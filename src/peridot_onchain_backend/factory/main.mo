import PeridotRegistry "canister:peridot_registry";

import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Error "mo:base/Error";

// 🔹 GANTI: Impor tipe PGC1 yang benar
import IPGC1 "../__core__/types/IPGC1";
import PGC1 "../__core__/shared/PGC1";
import GRT "../registry/types/GameRecordTypes";
import Core "../__core__/Core";

/*
    - update controller & admin
*/

// ===== Factory Actor - MUST BE LAST =====
shared ({ caller = owner }) persistent actor class PeridotFactory(
  _registry : ?Principal
) = this {
  // ===== IC Management Canister =====
  type CanisterSettings = {
    controllers : ?[Principal];
    freezing_threshold : ?Nat;
    memory_allocation : ?Nat;
    compute_allocation : ?Nat;
  };

  type UpdateSettingsArgs = {
    canister_id : Principal;
    settings : CanisterSettings;
  };

  type Management = actor {
    update_settings : (UpdateSettingsArgs) -> async ();
  };

  type Controllers = {
    registry : ?Principal;
  };

  let MGMT : Management = actor ("aaaaa-aa");

  private var controllers : Controllers = {
    registry = ?Principal.fromActor(PeridotRegistry);
  };

  private func isHaveAuthority(p : Principal) : async Bool {
    let isOwner = Principal.equal(p, owner);

    let isRegistry = switch (controllers.registry) {
      case (?reg) Principal.equal(p, reg);
      case null false;
    };

    isOwner or isRegistry;
  };

  private var _defaultCycles : Nat = 2_000_000_000_000; // 2T cycles

  // 🔹 GANTI: Simpan sebagai PGC1, bukan PGL1
  private var _createdPGC1s : [(Principal, IPGC1.init)] = [];

  // ===== Configuration =====
  public shared ({ caller }) func set_controllers(newControllers : Controllers) : async Bool {
    assert (await isHaveAuthority(caller));
    controllers := newControllers;
    true;
  };

  public query func get_controllers() : async Controllers { controllers };

  public shared ({ caller }) func set_default_cycles(n : Nat) : async Bool {
    assert (await isHaveAuthority(caller));
    _defaultCycles := n;
    true;
  };

  public query func get_default_cycles() : async Nat { _defaultCycles };

  public shared ({ caller }) func createAndRegisterPGC1Paid(
    args : {
      meta : IPGC1.init;
      controllers_extra : ?[Principal];
    }
  ) : async {
    canister_id : Principal;
    registered : Bool;
    error : ?Text;
  } {
    // 1) create PGC1
    let cid = await createPGC1({
      caller = caller;
      meta = args.meta;
      controllers_extra = args.controllers_extra;
    });

    // 2) register berbayar (payer = caller / developer)
    let record : GRT.CreateGameRecord = { canister_id = cid };
    let res = await PeridotRegistry.register_game_with_fee_for(record, caller);

    switch (res) {
      case (#ok _rec) { { canister_id = cid; registered = true; error = null } };
      case (#err e) {
        { canister_id = cid; registered = false; error = ?debug_show (e) };
      };
    };
  };

  // ================================================================
  // CREATE + REGISTER (WITH VOUCHER) ===============================
  // ================================================================

  // 🔹 Create PGC1 + Register menggunakan voucher code
  public shared ({ caller }) func createAndRegisterPGC1WithVoucher(
    args : {
      meta : IPGC1.init;
      controllers_extra : ?[Principal];
      voucher_code : Text;
    }
  ) : async {
    canister_id : Principal;
    registered : Bool;
    error : ?Text;
  } {
    // 1) Verify voucher valid SEBELUM create canister (save cycles!)
    let isValid = await PeridotRegistry.is_voucher_valid(args.voucher_code);
    if (not isValid) {
      return {
        canister_id = Principal.fromText("aaaaa-aa"); // placeholder
        registered = false;
        error = ?"Invalid or expired voucher code";
      };
    };

    // 2) Create PGC1 canister
    let cid = await createPGC1({
      caller = caller;
      meta = args.meta;
      controllers_extra = args.controllers_extra;
    });

    // 3) Register dengan voucher
    let record : GRT.CreateGameRecord = { canister_id = cid };
    let res = await PeridotRegistry.redeem_voucher(args.voucher_code, record);

    switch (res) {
      case (#ok _rec) { { canister_id = cid; registered = true; error = null } };
      case (#err e) {
        {
          canister_id = cid;
          registered = false;
          error = ?debug_show (e);
        };
      };
    };
  };

  func operation() : async () {
    Debug.print("Operation balance: " # debug_show (Cycles.balance()));
    Debug.print("Operation available: " # debug_show (Cycles.available()));
    let obtained = Cycles.accept<system>(_defaultCycles);
    Debug.print("Operation obtained: " # debug_show (obtained));
    Debug.print("Operation balance: " # debug_show (Cycles.balance()));
    Debug.print("Operation available: " # debug_show (Cycles.available()));
  };

  // ===== CREATE PGC1 CANISTER =====
  private func createPGC1(
    args : {
      caller : Principal;
      meta : IPGC1.init; // 🔹 Tipe baru
      controllers_extra : ?[Principal];
    }
  ) : async Principal {
    let regP : Principal = switch (controllers.registry) {
      case (null) Debug.trap("Factory: registry principal not set");
      case (?r) (r);
    };

    // Determine cycles
    let cycles_amount = _defaultCycles;

    // 1) Create PGC1 canister with cycles
    Cycles.add<system>(cycles_amount);
    await operation();

    // 🔹 Panggil PGC1 dengan 7 argumen (termasuk tokenCanister)
    let pgc1_actor = await PGC1.PGC1(
      args.meta.initGameId,
      args.meta.initName,
      args.meta.initDescription,
      args.meta.initMetadataURI,
      args.meta.initPrice,
      args.meta.initMaxSupply,
      args.meta.initTokenCanister, // 🔹 Ini yang baru!
      Principal.fromText(Core.PeridotAccount),
    );
    let canister_id = Principal.fromActor(pgc1_actor);

    // 2) Update controllers
    let baseCtrls : [Principal] = [Principal.fromActor(this), regP, args.caller];
    let ctrls = switch (args.controllers_extra) {
      case (null) baseCtrls;
      case (?xs) Array.append(baseCtrls, xs);
    };

    try {
      await MGMT.update_settings({
        canister_id;
        settings = {
          controllers = ?ctrls;
          freezing_threshold = null;
          memory_allocation = null;
          compute_allocation = null;
        };
      });
    } catch (e) {
      Debug.trap("Failed to update settings: " # Error.message(e));
    };

    // 3) Track created canister
    _createdPGC1s := Array.append(_createdPGC1s, [(canister_id, args.meta)]);

    canister_id;
  };

  // ===== Query Functions =====
  public query func get_created_pgc1s() : async [(Principal, IPGC1.init)] {
    _createdPGC1s;
  };

  public query func get_pgc1_count() : async Nat {
    _createdPGC1s.size();
  };

  public shared func get_pgc1_info(canister_id : Principal) : async {
    game_id : Text;
    name : Text;
    owner : Principal;
  } {
    let pgc1 : actor {
      getGameId : () -> async Text;
      getName : () -> async Text;
      getOwner : () -> async Principal;
    } = actor (Principal.toText(canister_id));

    {
      game_id = await pgc1.getGameId();
      name = await pgc1.getName();
      owner = await pgc1.getOwner();
    };
  };

  public shared ({ caller }) func list_my_pgc1_min(
    only_unregistered : ?Bool
  ) : async [{
    canister_id : Principal;
    game_id : Text;
    name : Text;
    registered : Bool;
  }] {
    let onlyUnreg : Bool = switch (only_unregistered) {
      case (?x) x;
      case null false;
    };

    var out : [{
      canister_id : Principal;
      game_id : Text;
      name : Text;
      registered : Bool;
    }] = [];

    for ((cid, _) in _createdPGC1s.vals()) {
      let pgc1 : actor {
        getOwner : () -> async Principal;
        getName : () -> async Text;
        getGameId : () -> async Text;
      } = actor (Principal.toText(cid));

      let owner = await pgc1.getOwner();

      if (Principal.equal(owner, caller)) {
        let isReg = await PeridotRegistry.isGameRegistered(cid);
        if (not (onlyUnreg and isReg)) {
          let nm = await pgc1.getName();
          let gid = await pgc1.getGameId();
          out := Array.append(out, [{ canister_id = cid; game_id = gid; name = nm; registered = isReg }]);
        };
      };
    };

    out;
  };
};
