import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Error "mo:base/Error";

import T "types/PGL1Types";
import PGL1 "canisters/PGL1";

// ===== Factory Actor - MUST BE LAST =====
shared ({ caller = owner }) persistent actor class Factory(platform_default : ?Principal) = this {
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

  let MGMT : Management = actor ("aaaaa-aa");

  // PGL1 Interface
  type PGL1Interface = actor {
    pgl1_set_platform : (Principal) -> async Bool;
    pgl1_set_distribution : ([T.Distribution]) -> async Bool;
  };

  private var _platform : ?Principal = platform_default;
  private var _defaultCycles : Nat = 2_000_000_000_000; // 2T cycles
  private var _createdPGL1s : [(Principal, T.PGLContractMeta)] = [];

  // ===== Configuration =====
  public shared ({ caller }) func set_platform(p : Principal) : async Bool {
    assert (caller == owner);
    _platform := ?p;
    true;
  };

  public query func get_platform() : async ?Principal { _platform };

  public shared ({ caller }) func set_default_cycles(n : Nat) : async Bool {
    assert (caller == owner);
    _defaultCycles := n;
    true;
  };

  public query func get_default_cycles() : async Nat { _defaultCycles };

  // ===== CREATE PGL1 CANISTER =====
  public shared ({ caller }) func createPGL1(
    args : {
      meta : T.PGLContractMeta;
      platform : ?Principal;
      controllers_extra : ?[Principal];
      cycles : ?Nat;
    }
  ) : async Principal {

    // Determine platform
    let platform : Principal = switch (args.platform, _platform) {
      case (?p, _) p;
      case (null, ?p) p;
      case (null, null) Debug.trap("Factory: platform principal not set");
    };

    // Determine cycles
    let cycles_amount = switch (args.cycles) {
      case (null) _defaultCycles;
      case (?n) n;
    };

    // 1) Create PGL1 canister with cycles
    Cycles.add(cycles_amount);
    let pgl1_actor = await PGL1.PGL1(?args.meta);
    let canister_id = Principal.fromActor(pgl1_actor);

    // 2) Update controllers
    let baseCtrls : [Principal] = [owner, Principal.fromActor(this)];
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
    let pgl1 : PGL1Interface = pgl1_actor;

    try {
      ignore await pgl1.pgl1_set_platform(platform);
    } catch (e) {
      Debug.trap("Failed to set platform: " # Error.message(e));
    };

    // 4) Set distribution if provided
    switch (args.meta.pgl1_distribution) {
      case (null) {};
      case (?list) {
        try {
          ignore await pgl1.pgl1_set_distribution(list);
        } catch (e) {
          Debug.trap("Failed to set distribution: " # Error.message(e));
        };
      };
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
  } {
    let pgl1 : actor {
      pgl1_game_id : () -> async Text;
      pgl1_name : () -> async Text;
    } = actor (Principal.toText(canister_id));

    {
      game_id = await pgl1.pgl1_game_id();
      name = await pgl1.pgl1_name();
    };
  };
};
