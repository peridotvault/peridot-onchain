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

persistent actor PeridotApp {
  // TYPES ==========================================================
  type AppType = AppTypes.App;
  type PurchaseType = PurchaseTypes.Purchase;
  type ApiResponse<T> = Core.ApiResponse<T>;

  // SNAPSHOTS ======================================================
  private var nextId : Core.AppId = 0;
  private var appEntries : [(Core.AppId, AppType)] = [];
  private var purchaseEntries : [(Core.UserId, [PurchaseType])] = [];

  // STATE ==========================================================
  private transient let appIdHash = func(id : Core.AppId) : Hash.Hash {
    Text.hash(Nat.toText(id));
  };
  private transient var apps : AppTypes.AppHashMap = HashMap.HashMap(0, Nat.equal, appIdHash);
  private transient var purchases : PurchaseTypes.PurchaseHashMap = HashMap.HashMap(0, Principal.equal, Principal.hash);

  // SYSTEM =========================================================
  system func preupgrade() {
    appEntries := Iter.toArray(apps.entries());
    purchaseEntries := Iter.toArray(purchases.entries());
  };

  system func postupgrade() {
    apps := HashMap.fromIter<Core.AppId, AppType>(appEntries.vals(), 1, Nat.equal, appIdHash);
    purchases := HashMap.fromIter<Core.UserId, [PurchaseType]>(purchaseEntries.vals(), 1, Principal.equal, Principal.hash);

    appEntries := [];
    purchaseEntries := [];
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

  public query func getAppById(appId : Core.AppId) : async ApiResponse<AppType> {
    AppService.getAppById(apps, appId);
  };

  public shared (msg) func getAppByDeveloperId() : async ApiResponse<[AppType]> {
    AppService.getAppByDeveloperId(apps, msg.caller);
  };

  public shared (msg) func getMyApps() : async ApiResponse<[AppType]> {
    await AppService.getMyApps(apps, purchases, msg.caller);
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

  // get

};
