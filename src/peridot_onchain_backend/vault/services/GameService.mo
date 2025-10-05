import PeridotRegistry "canister:peridot_registry";

import PGL1 "../../_core_/shared/PGL1Ledger";
import PGL1Types "../../_core_/types/PGL1Types";
import GRT "../../registry/types/GameRecordTypes";

import Core "./../../_core_/Core";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import GameAnnouncementTypes "../types/GameAnnouncementTypes";
import PurchaseTypes "../types/PurchaseTypes";
import GameTypes "../types/GameTypes";
import Helpers "../../_core_/Helpers";

module GameServiceModule {
  // TYPES ==========================================================
  type ApiResponse<T> = Core.ApiResponse<T>;
  type PGL1Ledger = PGL1.PGL1Ledger;
  type PGLMeta = PGL1Types.PGLContractMeta;
  type GameRecord = GRT.GameRecord;
  type GameAnnouncementType = GameAnnouncementTypes.GameAnnouncement;
  type GameAnnouncementInteractionType = GameAnnouncementTypes.GameAnnouncementInteraction;
  type PurchaseType = PurchaseTypes.Purchase;
  type AnnUserKey = GameAnnouncementTypes.AnnUserKey;
  type OwnedGame = GameTypes.OwnedGame;

  let PAGE : Nat = 200;

  func asPGL1(canisterIdTxt : Text) : PGL1.PGL1Ledger {
    actor (canisterIdTxt);
  };

  public func getGameMetadata(gameCanisterId : Text) : async PGL1Types.PGLContractMeta {
    let isReg = await PeridotRegistry.isGameRegistered(Principal.fromText(gameCanisterId));
    assert (isReg);
    let pgl1 : PGL1Ledger = asPGL1(gameCanisterId);
    await pgl1.pgl1_game_metadata();
  };

  public func getAllGames(start : Nat, limit : Nat) : async [PGLMeta] {
    let recsResp = await PeridotRegistry.getAllGameRecordLimit(start, limit);
    let recs = Helpers.expectOk<[GameRecord]>(recsResp, "getAllGameRecord");

    var out : [PGLMeta] = [];
    for (rec in recs.vals()) {
      let meta = await asPGL1(Principal.toText(rec.canister_id)).pgl1_game_metadata();
      out := Array.append(out, [meta]);
    };
    out;
  };

  public func getGamesByGameId(gameId : Text) : async ?PGLMeta {
    label scan while (true) {
      let resp = await PeridotRegistry.getAllGameRecord();
      let recs = Helpers.expectOk<[GameRecord]>(resp, "getAllGameRecord");
      if (recs.size() == 0) break scan;

      for (rec in recs.vals()) {
        if (rec.game_id == gameId) {
          let meta = await asPGL1(Principal.toText(rec.canister_id)).pgl1_game_metadata();
          return ?meta;
        };
      };
    };
    null;
  };

  public func getGameByDeveloperId(dev : Principal, start : Nat, limit : Nat) : async [PGLMeta] {
    let recsResp = await PeridotRegistry.getAllGameRecordLimit(start, limit);
    let recs = Helpers.expectOk<[GameRecord]>(recsResp, "getAllGameRecord");

    // NOTE: jika tipe developer kamu bukan Principal, sesuaikan perbandingannya.
    let mine = Array.filter<GameRecord>(
      recs,
      func(r : GameRecord) : Bool {
        Principal.equal(r.developer, dev);
      },
    );

    var out : [PGLMeta] = [];
    for (rec in mine.vals()) {
      let meta = await asPGL1(Principal.toText(rec.canister_id)).pgl1_game_metadata();
      out := Array.append(out, [meta]);
    };
    out;
  };

  public func getMyGames(caller : Principal) : async [OwnedGame] {
    var all : [OwnedGame] = [];
    var s : Nat = 0;

    label lp while (true) {
      let recsResp = await PeridotRegistry.getAllGameRecordLimit(s, PAGE);
      let recs = Helpers.expectOk<[GameRecord]>(recsResp, "getAllGameRecordLimit");
      if (recs.size() == 0) break lp;

      for (rec in recs.vals()) {
        let ok = await asPGL1(Principal.toText(rec.canister_id)).verify_license(caller);
        all := Array.append(all, [{ game_id = rec.game_id; canister_id = rec.canister_id; owned = ok }]);
      };

      s += PAGE;
    };

    all;
  };

  public func verify_license(gameCanisterId : Text, caller : Principal) : async Bool {
    let isReg = await PeridotRegistry.isGameRegistered(Principal.fromText(gameCanisterId));
    assert (isReg);
    let pgl1 : PGL1Ledger = asPGL1(gameCanisterId);
    await pgl1.verify_license(caller);
  };
};
