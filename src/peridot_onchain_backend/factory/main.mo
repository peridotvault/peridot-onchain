import PeridotRegistry "canister:peridot_registry";
import PeridotVault "canister:peridot_vault";
import PeridotDirectory "canister:peridot_directory";

import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Error "mo:base/Error";

import T "../_core_/types/PGL1Types";
import PGL1 "../_core_/shared/PGL1Ledger";

/*
    - update controller & admin
*/

// ===== Factory Actor - MUST BE LAST =====
shared ({ caller = owner }) persistent actor class PeridotFactory(
  _registry : ?Principal,
  _hub : ?Principal,
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
    hub : ?Principal;
  };

  let MGMT : Management = actor ("aaaaa-aa");

  private var controllers : Controllers = {
    registry = ?Principal.fromActor(PeridotRegistry);
    hub = ?Principal.fromActor(PeridotVault);
  };

  private func isHaveAuthority(p : Principal) : async Bool {
    let isOwner = Principal.equal(p, owner);

    let isRegistry = switch (controllers.registry) {
      case (?reg) Principal.equal(p, reg);
      case null false;
    };

    let isVault = switch (controllers.hub) {
      case (?hb) Principal.equal(p, hb);
      case null false;
    };

    let isDev = await PeridotDirectory.isUserDeveloper(p);

    // ekspresi terakhir mengembalikan Bool (tidak pakai ';')
    isOwner or isRegistry or isVault or isDev;
  };
  // private var controllers : Controllers = { registry = registry; hub = hub };
  private var _defaultCycles : Nat = 2_000_000_000_000; // 2T cycles
  private var _createdPGL1s : [(Principal, T.PGLContractMeta)] = [];

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

  // ===== CREATE PGL1 CANISTER =====
  public shared ({ caller }) func createPGL1(
    args : {
      meta : T.PGLContractMeta;
      controllers_extra : ?[Principal];
    }
  ) : async Principal {
    assert (await isHaveAuthority(caller));

    // Set Controllers for PGL Standard
    let (regP, hubP) : (Principal, Principal) = switch (controllers.registry, controllers.hub) {
      case (null, null) Debug.trap("Factory: controllers principal not set");
      case (null, ?_h) Debug.trap("Factory: registry principal not set");
      case (?_r, null) Debug.trap("Factory: hub principal not set");
      case (?r, ?h) (r, h); // <- r & h bertipe Principal (bukan ?Principal)
    };

    let pgl1_controllers : T.Controllers = {
      registry = ?regP;
      hub = ?hubP;
      developer = ?caller;
    };

    // Determine cycles
    let cycles_amount = _defaultCycles;

    // 1) Create PGL1 canister with cycles
    Cycles.add(cycles_amount);
    let pgl1_actor = await PGL1.PGL1Ledger(?args.meta);
    let canister_id = Principal.fromActor(pgl1_actor);

    // 2) Update controllers
    let baseCtrls : [Principal] = [Principal.fromActor(this), regP, hubP, caller];
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

    // 3) Initialize PGL1
    let pgl1 : PGL1.PGL1Ledger = pgl1_actor;

    try {
      ignore await pgl1.set_controllers(pgl1_controllers);
    } catch (e) {
      Debug.trap("Failed to set registry: " # Error.message(e));
    };

    // 5) Track created canister
    _createdPGL1s := Array.append(_createdPGL1s, [(canister_id, args.meta)]);

    canister_id;
  };

  // ===== Query Functions =====
  public query func get_created_pgl1s() : async [(Principal, T.PGLContractMeta)] {
    _createdPGL1s;
  };

  public query func get_pgl1_count() : async Nat {
    _createdPGL1s.size();
  };

  // ===== Get specific PGL1 info =====
  public shared func get_pgl1_info(canister_id : Principal) : async {
    game_id : Text;
    name : Text;
    controllers : T.Controllers;
  } {
    let pgl1 : actor {
      pgl1_game_id : () -> async Text;
      pgl1_name : () -> async Text;
      get_controllers : () -> async T.Controllers;
    } = actor (Principal.toText(canister_id));

    {
      game_id = await pgl1.pgl1_game_id();
      name = await pgl1.pgl1_name();
      controllers = await pgl1.get_controllers();
    };
  };

  public shared ({ caller }) func list_my_pgl1_min(
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

    for ((cid, _) in _createdPGL1s.vals()) {
      let pgl1 : actor {
        get_controllers : () -> async T.Controllers;
        pgl1_game_id : () -> async Text;
        pgl1_name : () -> async Text;
      } = actor (Principal.toText(cid));

      let ctrls = await pgl1.get_controllers();

      // hanya milik developer = caller
      switch (ctrls.developer) {
        case (?dev) {
          if (Principal.equal(dev, caller)) {
            let isReg = await PeridotRegistry.isGameRegistered(cid);
            if (onlyUnreg and isReg) {
              // skip yang sudah registered
            } else {
              let gid = await pgl1.pgl1_game_id();
              let nm = await pgl1.pgl1_name();
              out := Array.append(out, [{ canister_id = cid; game_id = gid; name = nm; registered = isReg }]);
            };
          };
        };
        case (null) {};
      };
    };

    out;
  }

};
