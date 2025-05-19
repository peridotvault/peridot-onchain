import TypeApp "./TypeApp";
import Core "./../Core";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";

actor PeridotApp {
    // TYPES ==========================================================
    type App = TypeApp.App;

    // STATE ==========================================================
    private stable var appEntries : [(Core.AppId, App)] = [];

    // VARIABLE =======================================================
    private let appIdHash = func(id : Nat) : Hash.Hash {
        Text.hash(Nat.toText(id));
    };
    private var apps = HashMap.HashMap<Core.AppId, App>(0, Nat.equal, appIdHash);

    // SYSTEM =========================================================
    system func preupgrade() {
        appEntries := Iter.toArray(apps.entries());
    };

    system func postupgrade() {
        apps := HashMap.fromIter<Core.AppId, App>(appEntries.vals(), 1, Nat.equal, appIdHash);

        appEntries := [];
    };

    //  ===============================================================
    // App ============================================================
    //  ===============================================================
    // CREATE
    public shared (msg) func createApp(app : App) : async App {
        return app;
    };
};
