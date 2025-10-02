import AppTypes "./types/AppTypes";
import PurchaseTypes "types/PurchaseTypes";
import AppService "services/AppService";
import PurchaseService "services/PurchaseService";

import Core "./../core/Core";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import AppAnnouncementTypes "types/AppAnnouncementTypes";
import AppAnnouncementService "services/AppAnnouncementService";

persistent actor PeridotApp {
  // TYPES ==========================================================
  type AppType = AppTypes.App;
  type AppAnnouncementType = AppAnnouncementTypes.AppAnnouncement;
  type AppAnnouncementInteractionType = AppAnnouncementTypes.AppAnnouncementInteraction;
  type PurchaseType = PurchaseTypes.Purchase;
  type ApiResponse<T> = Core.ApiResponse<T>;
  type AnnUserKey = AppAnnouncementTypes.AnnUserKey;

  // SNAPSHOTS ======================================================
  private var nextId : Core.AppId = 0;
  private var nextAnnouncementId : Core.AnnouncementId = 0;

  private var appEntries : [(Core.AppId, AppType)] = [];
  private var purchaseEntries : [(Core.UserId, [PurchaseType])] = [];
  private var announcementEntries : [(Core.AnnouncementId, AppAnnouncementType)] = [];
  private var interactionEntries : [(AnnUserKey, AppAnnouncementInteractionType)] = [];

  // STATE ==========================================================
  private transient let appIdHash = func(id : Core.AppId) : Hash.Hash {
    Text.hash(Nat.toText(id));
  };
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

  private transient var apps : AppTypes.AppHashMap = HashMap.HashMap(8, Nat.equal, appIdHash);
  private transient var purchases : PurchaseTypes.PurchaseHashMap = HashMap.HashMap(8, Principal.equal, Principal.hash);
  private transient var announcements : AppAnnouncementTypes.AppAnnouncementHashMap = HashMap.HashMap(8, Nat.equal, announcementIdHash);
  private transient var annInteractions : AppAnnouncementTypes.AppAnnouncementInteractionHashMap = HashMap.HashMap(8, annUserEq, annUserHash);

  // SYSTEM =========================================================
  system func preupgrade() {
    appEntries := Iter.toArray(apps.entries());
    purchaseEntries := Iter.toArray(purchases.entries());
    announcementEntries := Iter.toArray(announcements.entries());
    interactionEntries := Iter.toArray(annInteractions.entries());
  };

  system func postupgrade() {
    apps := HashMap.fromIter<Core.AppId, AppType>(appEntries.vals(), 8, Nat.equal, appIdHash);
    purchases := HashMap.fromIter<Core.UserId, [PurchaseType]>(purchaseEntries.vals(), 8, Principal.equal, Principal.hash);
    announcements := HashMap.fromIter<Core.AnnouncementId, AppAnnouncementType>(announcementEntries.vals(), 8, Nat.equal, appIdHash);
    annInteractions := HashMap.fromIter<AnnUserKey, AppAnnouncementInteractionType>(interactionEntries.vals(), 8, annUserEq, annUserHash);

    appEntries := [];
    purchaseEntries := [];
    announcementEntries := [];
    interactionEntries := [];
  };

  //  ===============================================================
  // App ============================================================
  //  ===============================================================
  // create
  public shared (msg) func createApp(createApp : AppTypes.CreateApp) : async ApiResponse<AppType> {
    let id = nextId;
    nextId += 1;
    await AppService.createApp(apps, msg.caller, createApp, id);
  };

  // get
  public query func getAllApps() : async ApiResponse<[AppType]> {
    AppService.getAllApps(apps);
  };

  public query func getAllPublishApps() : async ApiResponse<[AppType]> {
    AppService.getAllPublishApps(apps);
  };

  public query func getAppById(appId : Core.AppId) : async ApiResponse<AppType> {
    AppService.getAppById(apps, appId);
  };

  public shared (msg) func getAppByDeveloperId() : async ApiResponse<[AppType]> {
    AppService.getAppByDeveloperId(apps, msg.caller);
  };

  public shared (msg) func getMyApps() : async ApiResponse<[AppType]> {
    await AppService.getMyApps(apps, purchases, msg.caller);
  };

  public query func getTotalBuyers(appId : Core.AppId) : async ApiResponse<Nat> {
    AppService.getTotalBuyers(appId, purchases);
  };

  // update
  public shared (msg) func updateApp(updateApp : AppTypes.UpdateApp, appId : Core.AppId) : async ApiResponse<AppType> {
    await AppService.updateApp(apps, msg.caller, appId, updateApp);
  };

  // delete
  public shared (msg) func deleteApp(appId : Core.AppId) : async ApiResponse<Text> {
    await AppService.deleteApp(apps, msg.caller, appId);
  };

  //  ===============================================================
  // Purchase =======================================================
  //  ===============================================================
  // create
  public shared (msg) func buyApp(appId : Nat) : async ApiResponse<PurchaseType> {
    let spenderPrincipal = Principal.fromActor(PeridotApp);
    let merchant = Principal.fromText(Core.PeridotAccount);
    await PurchaseService.buyApp(purchases, apps, appId, msg.caller, Core.TokenLedgerCanister, spenderPrincipal, merchant);
  };

  //  ===============================================================
  // Announcement ===================================================
  //  ===============================================================
  // announcementInteraction like/dislike by AnnId
  // CREATE
  public shared (msg) func createAnnouncement(appId : Core.AppId, annInput : AppAnnouncementTypes.DTOAppAnnouncement) : async ApiResponse<AppAnnouncementType> {
    let id = nextAnnouncementId;
    nextAnnouncementId += 1;
    AppAnnouncementService.createAnnouncement(announcements, apps, appId, msg.caller, annInput, id);
  };

  // GET
  public query func getAllAnnouncementsByAppId(appId : Core.AppId) : async ApiResponse<[AppAnnouncementType]> {
    AppAnnouncementService.getAllAnnouncementsByAppId(announcements, appId);
  };

  public query func getAnnouncementsByAnnouncementId(announcementId : Core.AnnouncementId) : async ApiResponse<AppAnnouncementType> {
    AppAnnouncementService.getAnnouncementsByAnnouncementId(announcements, announcementId);
  };

  // UPDATE
  public shared (msg) func updateAnnouncement(announcementId : Core.AnnouncementId, annInput : AppAnnouncementTypes.DTOAppAnnouncement) : async ApiResponse<AppAnnouncementType> {
    AppAnnouncementService.updateAnnouncement(announcements, msg.caller, annInput, announcementId);
  };

  // DELETE
  public shared (msg) func deleteAnnouncement(announcementId : Core.AnnouncementId) : async ApiResponse<Text> {
    AppAnnouncementService.deleteAnnouncement(announcements, msg.caller, announcementId);
  };

  //  ===============================================================
  // Announcement Interactions ======================================
  //  ===============================================================
  public shared (msg) func likeByAnnouncementId(announcementId : Core.AnnouncementId) : async ApiResponse<AppAnnouncementInteractionType> {
    AppAnnouncementService.likeByAnnouncementId(announcements, annInteractions, announcementId, msg.caller);
  };

  public shared (msg) func dislikeByAnnouncementId(announcementId : Core.AnnouncementId) : async ApiResponse<AppAnnouncementInteractionType> {
    AppAnnouncementService.dislikeByAnnouncementId(announcements, annInteractions, announcementId, msg.caller);
  };

  public shared (msg) func unLikeDislikeByAnnouncementId(announcementId : Core.AnnouncementId) : async ApiResponse<AppAnnouncementInteractionType> {
    AppAnnouncementService.unLikeDislikeByAnnouncementId(announcements, annInteractions, announcementId, msg.caller);
  };

  public shared (msg) func commentByAnnouncementId(announcementId : Core.AnnouncementId, comment : Text) : async ApiResponse<AppAnnouncementInteractionType> {
    AppAnnouncementService.commentByAnnouncementId(announcements, annInteractions, announcementId, msg.caller, comment);
  };
};
