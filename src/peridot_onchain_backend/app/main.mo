import TypeApp "./TypeApp";
import Core "./../Core";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";

actor PeridotApp {
    // TYPES ==========================================================
    // type App = TypeApp.App;
    type ApiResponse<T> = Core.ApiResponse<T>;

    // STATE ==========================================================
    // private stable var appEntries : [(Core.AppId, App)] = [];

    // VARIABLE =======================================================
    // private let appIdHash = func(id : Nat) : Hash.Hash {
    //     Text.hash(Nat.toText(id));
    // };
    // private var apps = HashMap.HashMap<Core.AppId, App>(0, Nat.equal, appIdHash);

    // // SYSTEM =========================================================
    // system func preupgrade() {
    //     appEntries := Iter.toArray(apps.entries());
    // };

    // system func postupgrade() {
    //     apps := HashMap.fromIter<Core.AppId, App>(appEntries.vals(), 1, Nat.equal, appIdHash);

    //     appEntries := [];
    // };

    //  ===============================================================
    // App ============================================================
    //  ===============================================================

    // DUMMY 🚫 =======================================================
    // DUMMY 🚫 =======================================================
    // DUMMY 🚫 =======================================================
    public type DummyApp = {
        id : Nat;
        owner : Principal;
        title : Text;
        cover_image : Text;
        background_image : Text;
        price : Nat64;
    };

    // Variabel state untuk menyimpan aplikasi dan ID
    private var nextId : Nat = 0;
    private var appsEntries : [(Nat, DummyApp)] = [];
    private var purchasesEntries : [(Principal, [Nat])] = [];

    // HashMap untuk aplikasi dan pembelian
    private let appIdHash = func(id : Nat) : Hash.Hash {
        Text.hash(Nat.toText(id));
    };
    private var apps = HashMap.HashMap<Nat, DummyApp>(0, Nat.equal, appIdHash);
    private var purchases = HashMap.HashMap<Principal, [Nat]>(0, Principal.equal, Principal.hash);

    // Membuat aplikasi baru
    public shared (msg) func createApp(
        title : Text,
        cover_image : Text,
        background_image : Text,
        price : Nat64,
    ) : async DummyApp {

        let id = nextId;
        nextId += 1;

        let app : DummyApp = {
            id = id;
            owner = msg.caller;
            title = title;
            cover_image = cover_image;
            background_image = background_image;
            price = price;
        };

        apps.put(id, app);
        return app;
    };

    // Mendapatkan semua aplikasi
    public query func getAllApps() : async [DummyApp] {
        let values = Iter.toArray(apps.vals());
        return values;
    };

    // Mendapatkan aplikasi berdasarkan ID
    public query func getApp(id : Nat) : async ?DummyApp {
        return apps.get(id);
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
    public query ({ caller }) func getMyPurchasedApps() : async [DummyApp] {
        let purchasedIds = getUserPurchases(caller);
        let purchasedApps = Buffer.Buffer<DummyApp>(0);

        for (id in purchasedIds.vals()) {
            switch (apps.get(id)) {
                case (?app) { purchasedApps.add(app) };
                case (null) { /* App not found, skip */ };
            };
        };

        return Buffer.toArray(purchasedApps);
    };

};
