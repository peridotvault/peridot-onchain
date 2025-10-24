// File: services/GameRecordServices.mo
import GRT "../types/GameRecordTypes";

import Helpers "../../_core_/Helpers";
import Core "../../_core_/Core";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import TokenLedger "../../_core_/shared/TokenLedger";
import PaymentService "../../_core_/services/Purchase";

module GameRecordServices {
  type ApiResponse<T> = Core.ApiResponse<T>;
  type GameRecordType = GRT.GameRecord;

  public func register_game(
    gameRecords : GRT.GameRecordHashMap,
    caller : Principal,
    createGameRecord : GRT.CreateGameRecord,
  ) : async ApiResponse<GameRecordType> {
    // 🔹 Buat actor PGC1
    let pgc1 : actor {
      getGameId : () -> async Core.GameId;
      getOwner : () -> async Principal;
    } = actor (Principal.toText(createGameRecord.canister_id));

    // Ambil data dari canister PGC1
    let gameId = await pgc1.getGameId();
    let owner = await pgc1.getOwner();

    if (not Principal.equal(caller, owner)) {
      return #err(#Unauthorized("Only PGC1 owner can register"));
    };

    // 🔒 Duplikasi by gameId
    switch (gameRecords.get(gameId)) {
      case (?_) {
        return #err(#ValidationError("Game already registered (by gameId)"));
      };
      case null {};
    };

    // 🔒 Duplikasi by canister_id
    if (isGameRegistered(gameRecords, createGameRecord.canister_id)) {
      return #err(#ValidationError("Game already registered (by canister_id)"));
    };

    let gameRecordNewData : GameRecordType = {
      game_id = gameId;
      canister_id = createGameRecord.canister_id;
      developer = owner; // 🔹 Ambil dari PGC1, bukan dari input
      status = null;
      register_at = Time.now();
    };

    gameRecords.put(gameId, gameRecordNewData);
    #ok(gameRecordNewData);
  };

  public func register_game_with_fee(
    gameRecords : GRT.GameRecordHashMap,
    caller : Principal,
    createGameRecord : GRT.CreateGameRecord,
    fee_amount : Nat,
    fee_token_address : ?Principal,
    treasury_address : ?Principal,
    peridotRegistry : Principal,
  ) : async ApiResponse<GameRecordType> {
    // 1) ambil config
    let token = switch (fee_token_address) {
      case (?t) t;
      case null return #err(#ValidationError("Registry fee token not configured"));
    };
    let dst = switch (treasury_address) {
      case (?t) t;
      case null return #err(#ValidationError("Registry treasury not configured"));
    };

    // 2) tarik fee dari caller → treasury (spender = PeridotRegistry)
    let ledger : TokenLedger.Self = actor (Principal.toText(token));
    let payRes = await PaymentService.pay(
      ledger,
      caller,
      dst,
      peridotRegistry,
      fee_amount,
    );
    switch (payRes) { case (#err e) return #err(e); case (#ok _tx) {} };

    // 3) lanjut register record
    await register_game(gameRecords, caller, createGameRecord);
  };

  public func register_game_with_fee_for(
    gameRecords : GRT.GameRecordHashMap,
    createGameRecord : GRT.CreateGameRecord,
    fee_amount : Nat,
    fee_token_address : ?Principal,
    treasury_address : ?Principal,
    peridotRegistry : Principal,
    payer : Principal,
  ) : async ApiResponse<GameRecordType> {
    // 0) config ready?
    let token = switch (fee_token_address) {
      case (?t) t;
      case null return #err(#ValidationError("Registry fee token not configured"));
    };
    let dst = switch (treasury_address) {
      case (?t) t;
      case null return #err(#ValidationError("Registry treasury not configured"));
    };

    // 1) Safety: verifikasi payer adalah owner dari canister yang didaftarkan
    let pgc1 : actor {
      getOwner : () -> async Principal;
    } = actor (Principal.toText(createGameRecord.canister_id));
    let owner = await pgc1.getOwner();
    if (owner != payer) {
      return #err(#NotAuthorized("Payer must be the owner/developer of the PGC1 canister"));
    };

    // 2) Tarik fee dari payer → treasury (spender = Registry)
    let ledger : TokenLedger.Self = actor (Principal.toText(token));
    let payRes = await PaymentService.pay(
      ledger,
      payer,
      dst,
      peridotRegistry,
      fee_amount,
    );
    switch (payRes) { case (#err e) return #err(e); case (#ok _tx) {} };

    // 3) Lanjut simpan catatan
    await register_game(gameRecords, payer, createGameRecord);
  };

  // 🔹 Sisanya tetap sama (tidak perlu ubah)
  public func isGameRegistered(
    gameRecords : GRT.GameRecordHashMap,
    canisterId : Principal,
  ) : Bool {
    var found = false;
    label scan for ((_, rec) in gameRecords.entries()) {
      if (Principal.equal(rec.canister_id, canisterId)) {
        found := true;
        break scan;
      };
    };
    found;
  };

  public func getAllGameRecordLimit(
    gameRecords : GRT.GameRecordHashMap,
    start : Nat,
    limit : Nat,
  ) : ApiResponse<[GameRecordType]> {
    #ok(Helpers.sliceIter<GameRecordType>(gameRecords.vals(), start, limit));
  };

  public func getAllGameRecord(
    gameRecords : GRT.GameRecordHashMap
  ) : ApiResponse<[GameRecordType]> {
    #ok(Iter.toArray<GameRecordType>(gameRecords.vals()));
  };

  public func getGameRecordById(
    gameRecords : GRT.GameRecordHashMap,
    gameId : Core.GameId,
  ) : ApiResponse<GameRecordType> {
    switch (gameRecords.get(gameId)) {
      case (null) {
        #err(#NotFound("Game with Game Id " # gameId # " not registered"));
      };
      case (?game) { #ok(game) };
    };
  };

  public func getGameByDeveloperId(
    gameRecords : GRT.GameRecordHashMap,
    dev : Principal,
    gameId : Core.GameId,
  ) : async ApiResponse<GameRecordType> {
    switch (gameRecords.get(gameId)) {
      case (null) {
        #err(#NotFound("Game with Game Id " # gameId # " not registered"));
      };
      case (?game) {
        if (Principal.equal(game.developer, dev)) {
          #ok(game);
        } else {
          #err(#Unauthorized("You don't have access to get the Game Record"));
        };
      };
    };
  };
};
