import AppTypes "./types/AppTypes";
import Core "./../core/Core";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";

persistent actor PeridotApp {

  //  ===============================================================
  // App ============================================================
  //  ===============================================================
  type App = AppTypes.App;
  type ApiResponse<T> = Core.ApiResponse<T>;

  // Variabel state untuk menyimpan aplikasi dan ID
  private var nextId : Nat = 0;
  private var appsEntries : [(Nat, App)] = [];
  private var purchasesEntries : [(Principal, [Nat])] = [];

  // HashMap untuk aplikasi dan pembelian
  private transient let appIdHash = func(id : Nat) : Hash.Hash {
    Text.hash(Nat.toText(id));
  };
  private transient var apps = HashMap.HashMap<Nat, App>(0, Nat.equal, appIdHash);
  private transient var purchases = HashMap.HashMap<Principal, [Nat]>(0, Principal.equal, Principal.hash);

  // CREATE =========================================================
  public shared (msg) func createApp(
    app : App
  ) : async ApiResponse<App> {

    let id = nextId;
    nextId += 1;

    apps.put(id, app);
    #ok(app);
  };

  // Mendapatkan semua aplikasi
  public query func getAllApps() : async ApiResponse<[App]> {
    let values = Iter.toArray(apps.vals());
    #ok(values);
  };

  // Mendapatkan aplikasi berdasarkan ID
  public query func getApp(id : Nat) : async ApiResponse<App> {
    let app = apps.get(id);

    switch (app) {
      case (null) {
        return #err(#NotFound("App with ID " # Nat.toText(id) # " not found"));
      };
      case (?app) { return #ok(app) };
    };
  };

  // Memeriksa apakah sebuah angka ada dalam array
  private func containsNat(arr : [Nat], target : Nat) : Bool {
    for (item in arr.vals()) {
      if (item == target) {
        return true;
      };
    };
    return false;
  };

  // Mendapatkan pembelian pengguna
  private func getUserPurchases(user : Principal) : [Nat] {
    switch (purchases.get(user)) {
      case (?userPurchases) { return userPurchases };
      case (null) { return [] };
    };
  };

  // Membeli aplikasi
  public shared ({ caller }) func buyApp(appId : Nat) : async ApiResponse<Text> {
    switch (apps.get(appId)) {
      case (null) {
        return #err(#NotFound("The App not found"));
      };
      case (?app) {
        let userPurchases = getUserPurchases(caller);

        if (containsNat(userPurchases, appId)) {
          return #err(#AlreadyExists("You already bought this app"));

        };

        // Menambahkan ke pembelian user
        let newPurchases = Array.append(userPurchases, [appId]);
        purchases.put(caller, newPurchases);

        return #ok("App bought successfully");
      };
    };
  };

  // Mendapatkan aplikasi yang sudah dibeli
  public query ({ caller }) func getMyPurchasedApps() : async ApiResponse<[App]> {
    let purchasedIds = getUserPurchases(caller);
    let purchasedApps = Buffer.Buffer<App>(0);

    for (id in purchasedIds.vals()) {
      switch (apps.get(id)) {
        case (?app) { purchasedApps.add(app) };
        case (null) { /* App not found, skip */ };
      };
    };

    #ok(Buffer.toArray(purchasedApps));
  };

};
