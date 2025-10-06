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

  func asPGL1(canisterIdTxt : Text) : PGL1.PGL1Ledger {
    actor (canisterIdTxt);
  };

  // update
  public func updateGame(
    gameCanisterId : Text,
    _caller : Principal, // tidak dipakai; ACL dicek di PGL1 via msg.caller (Vault/hub)
    args : PGLMeta,
  ) : async PGLMeta {
    // 1) pastikan terdaftar
    let isReg = await PeridotRegistry.isGameRegistered(Principal.fromText(gameCanisterId));
    assert (isReg);

    // 2) siapkan actor PGL1
    let pgl1 : PGL1Ledger = asPGL1(gameCanisterId);

    // 3) bentuk patch dari PGLMeta -> PGLUpdateMeta
    //    Catatan:
    let patch : PGL1Types.PGLUpdateMeta = {
      game_id = ?args.pgl1_game_id;
      name = ?args.pgl1_name;
      description = ?args.pgl1_description;
      cover_image = ?args.pgl1_cover_image;
      price = ?args.pgl1_price;
      required_age = ?args.pgl1_required_age;
      banner_image = ?args.pgl1_banner_image;
      metadata = ?args.pgl1_metadata;
      website = ?args.pgl1_website;
      distribution = ?args.pgl1_distribution;
    };

    // 4) jalankan update (ACL: PGL1 menerima registry/dev/hub; Vault harus terdaftar sbg hub atau registry)
    ignore await pgl1.pgl1_update_meta(patch);

    // 5) ambil metadata terbaru & return
    await pgl1.pgl1_game_metadata();
  };

  // get
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

  public func getMyGames(caller : Principal) : async [PGLMeta] {
    let recsResp = await PeridotRegistry.getAllGameRecord();
    let recs = Helpers.expectOk<[GameRecord]>(recsResp, "getAllGameRecord");
    var out : [PGLMeta] = [];
    for (rec in recs.vals()) {
      let pgl1 = asPGL1(Principal.toText(rec.canister_id));
      let owned = await pgl1.verify_license(caller);
      if (owned) {
        let meta = await pgl1.pgl1_game_metadata();
        out := Array.append(out, [meta]);
      };
    };
    out;
  };

  public func verify_license(gameCanisterId : Text, caller : Principal) : async Bool {
    let isReg = await PeridotRegistry.isGameRegistered(Principal.fromText(gameCanisterId));
    assert (isReg);
    let pgl1 : PGL1Ledger = asPGL1(gameCanisterId);
    await pgl1.verify_license(caller);
  };
};
