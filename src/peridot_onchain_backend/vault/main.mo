import PeridotRegistry "canister:peridot_registry";

import PGL1 "../_core_/shared/PGL1Ledger";
import PGL1Types "../_core_/types/PGL1Types";
import GRT "../registry/types/GameRecordTypes";

import Core "./../_core_/Core";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import GameAnnouncementTypes "types/GameAnnouncementTypes";
import PurchaseTypes "types/PurchaseTypes";
import GameAnnouncementService "services/GameAnnouncementService";
import PurchaseService "services/PurchaseService";
import GameTypes "types/GameTypes";
import GameService "services/GameService";

/*
  Catalog
    - 🔄 all PGL methods (pgl1_game_metadata)
    - update PGL
    - ✅ verify_license
    - get_release_manifest(ref)
    - get_release_version(ref)
    - ✅ getAllGames
    - getAllPublishGames
    - ✅ getGamesByGameId
    - ✅ getGameByDeveloperId
    - ✅ getMyGames (dapatkan apakah game dimiliki/sudah di beli user)

  Store/Purchases
    - create_order(game_id, buyer, payment)
    - confirm_payment
    - fulfill_order -> registry_mint_to

  Ratings
    - rate_game
    - list_ratings

  Announcements
    - post_announcement
    - list_announcements

*/

persistent actor PeridotVault {
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

  // SNAPSHOTS ======================================================
  private var nextAnnouncementId : Core.AnnouncementId = 0;
  private var purchaseEntries : [(Core.UserId, [PurchaseType])] = [];
  private var announcementEntries : [(Core.AnnouncementId, GameAnnouncementType)] = [];
  private var interactionEntries : [(AnnUserKey, GameAnnouncementInteractionType)] = [];

  // STATE ==========================================================
  private transient let announcementIdHash = func(id : Core.AnnouncementId) : Hash.Hash {
    Text.hash(Nat.toText(id));
  };
  private transient let annUserEq = func(a : AnnUserKey, b : AnnUserKey) : Bool {
    a.annId == b.annId and Principal.equal(a.userId, b.userId)
  };
  private transient let annUserHash = func(k : AnnUserKey) : Hash.Hash {
    let t = Nat.toText(k.annId) # Principal.toText(k.userId);
    Text.hash(t);
  };

  private transient var purchases : PurchaseTypes.PurchaseHashMap = HashMap.HashMap(8, Principal.equal, Principal.hash);
  private transient var announcements : GameAnnouncementTypes.GameAnnouncementHashMap = HashMap.HashMap(8, Nat.equal, announcementIdHash);
  private transient var annInteractions : GameAnnouncementTypes.GameAnnouncementInteractionHashMap = HashMap.HashMap(8, annUserEq, annUserHash);

  // SYSTEM =========================================================
  system func preupgrade() {
    purchaseEntries := Iter.toArray(purchases.entries());
    announcementEntries := Iter.toArray(announcements.entries());
    interactionEntries := Iter.toArray(annInteractions.entries());
  };
  system func postupgrade() {
    purchases := HashMap.fromIter<Core.UserId, [PurchaseType]>(purchaseEntries.vals(), 8, Principal.equal, Principal.hash);
    announcements := HashMap.fromIter<Core.AnnouncementId, GameAnnouncementType>(announcementEntries.vals(), 8, Nat.equal, announcementIdHash);
    annInteractions := HashMap.fromIter<AnnUserKey, GameAnnouncementInteractionType>(interactionEntries.vals(), 8, annUserEq, annUserHash);

    purchaseEntries := [];
    announcementEntries := [];
    interactionEntries := [];
  };

  //  ===============================================================
  // Catalog ========================================================
  //  ===============================================================
  public shared func getGameMetadata(gameCanisterId : Text) : async PGL1Types.PGLContractMeta {
    await GameService.getGameMetadata(gameCanisterId);
  };

  public shared func getAllGames(start : Nat, limit : Nat) : async [PGLMeta] {
    await GameService.getAllGames(start, limit);
  };

  public shared func getGamesByGameId(gameId : Text) : async ?PGLMeta {
    await GameService.getGamesByGameId(gameId);
  };

  public shared func getGameByDeveloperId(dev : Principal, start : Nat, limit : Nat) : async [PGLMeta] {
    await GameService.getGameByDeveloperId(dev, start, limit);

  };

  public shared ({ caller }) func getMyGames() : async [OwnedGame] {
    await GameService.getMyGames(caller);
  };

  public shared ({ caller }) func verify_license(gameCanisterId : Text) : async Bool {
    await GameService.verify_license(gameCanisterId, caller);
  };

  //  ===============================================================
  // Store/Purchases ================================================
  //  ===============================================================
  public shared ({ caller }) func buyGame(gameId : Core.GameId) : async ApiResponse<PurchaseType> {
    let spenderPrincipal = Principal.fromActor(PeridotVault);
    let merchant = Principal.fromText(Core.PeridotAccount);
    await PurchaseService.buyGame(purchases, gameId, caller, Core.TokenLedgerCanister, spenderPrincipal, merchant);
  };

  //  ===============================================================
  // Announcements ==================================================
  //  ===============================================================
  // announcementInteraction like/dislike by AnnId
  // CREATE
  public shared ({ caller }) func createAnnouncement(gameId : Core.GameId, annInput : GameAnnouncementTypes.DTOGameAnnouncement) : async ApiResponse<GameAnnouncementType> {
    let announcementId = nextAnnouncementId;
    nextAnnouncementId += 1;
    await GameAnnouncementService.createAnnouncement(announcements, gameId, caller, annInput, announcementId);
  };

  // GET
  public query func getAllAnnouncementsByGameId(gameId : Core.GameId) : async ApiResponse<[GameAnnouncementType]> {
    GameAnnouncementService.getAllAnnouncementsByGameId(announcements, gameId);
  };

  public query func getAnnouncementsByAnnouncementId(announcementId : Core.AnnouncementId) : async ApiResponse<GameAnnouncementType> {
    GameAnnouncementService.getAnnouncementsByAnnouncementId(announcements, announcementId);
  };

  // UPDATE
  public shared ({ caller }) func updateAnnouncement(announcementId : Core.AnnouncementId, annInput : GameAnnouncementTypes.DTOGameAnnouncement) : async ApiResponse<GameAnnouncementType> {
    GameAnnouncementService.updateAnnouncement(announcements, caller, annInput, announcementId);
  };

  // DELETE
  public shared ({ caller }) func deleteAnnouncement(announcementId : Core.AnnouncementId) : async ApiResponse<Text> {
    GameAnnouncementService.deleteAnnouncement(announcements, caller, announcementId);
  };

  //  ===============================================================
  // Announcement Interactions ======================================
  //  ===============================================================
  public shared ({ caller }) func likeByAnnouncementId(announcementId : Core.AnnouncementId) : async ApiResponse<GameAnnouncementInteractionType> {
    GameAnnouncementService.likeByAnnouncementId(announcements, annInteractions, announcementId, caller);
  };

  public shared ({ caller }) func dislikeByAnnouncementId(announcementId : Core.AnnouncementId) : async ApiResponse<GameAnnouncementInteractionType> {
    GameAnnouncementService.dislikeByAnnouncementId(announcements, annInteractions, announcementId, caller);
  };

  public shared ({ caller }) func unLikeDislikeByAnnouncementId(announcementId : Core.AnnouncementId) : async ApiResponse<GameAnnouncementInteractionType> {
    GameAnnouncementService.unLikeDislikeByAnnouncementId(announcements, annInteractions, announcementId, caller);
  };

  public shared ({ caller }) func commentByAnnouncementId(announcementId : Core.AnnouncementId, comment : Text) : async ApiResponse<GameAnnouncementInteractionType> {
    GameAnnouncementService.commentByAnnouncementId(announcements, annInteractions, announcementId, caller, comment);
  };
};
