import AppTypes "./types/AppTypes";
import PurchaseTypes "types/PurchaseTypes";

import Core "./../core/Core";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import AppAnnouncementTypes "types/AppAnnouncementTypes";

import PGL1Types "types/PGL1Types"

persistent actor PeridotApp {
  // TYPES ==========================================================
  type AppType = AppTypes.App;
  type AppAnnouncementType = AppAnnouncementTypes.AppAnnouncement;
  type AppAnnouncementInteractionType = AppAnnouncementTypes.AppAnnouncementInteraction;
  type PurchaseType = PurchaseTypes.Purchase;
  type ApiResponse<T> = Core.ApiResponse<T>;
  type AnnUserKey = AppAnnouncementTypes.AnnUserKey;

  // SNAPSHOTS ======================================================
  private var nextGameId : Core.AppId = 0;
  private var init = {
    pgl1_cover_image : Text = "https://...";
    pgl1_name : Text = "PeridotVault Game";
    pgl1_description : Text = "PeridotVault Descriptions";
    pgl1_price : ?Nat = ?0;
    pgl1_required_age : ?Nat = ?0;
    pgl1_metadata : ?PGL1Types.Metadata = null;
  };

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
  // IGL-1 ==========================================================
  //  ===============================================================
  public query func pgl1_cover_image() : async Text {
    return init.pgl1_name;
  };

  public query func pgl1_name() : async Text {
    return init.pgl1_name;
  };

  public query func pgl1_description() : async Text {
    return init.pgl1_description;
  };

  public query func pgl1_price() : async ?Nat {
    return init.pgl1_price;
  };

  public query func pgl1_required_age() : async ?Nat {
    return init.pgl1_required_age;
  };

  public query func pgl1_metadata() : async ?PGL1Types.Metadata {
    return init.pgl1_metadata;
  };
};
