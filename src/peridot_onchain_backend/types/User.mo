import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Bool "mo:base/Bool";
import Nat "mo:base/Nat";
import Core "./Core";

module {
    public type Username = Text;

    public type User = {
        userId : Core.UserId;
        principalId : Principal;
        username : Username;
        displayName : ?Text;
        profileUrl : ?Text;
        email : ?Text;
        age : Nat;
        gender : Gender;
        country : Core.Country;
        userBehaviors : ?[UserBehavior];
        isDeveloper : Bool;
        createdAt : Core.Timestamp;
        lastLogin : Core.Timestamp;
    };

    // Gender =========================
    public type Gender = {
        #male;
        #female;
        #other;
    };

    // Behavior =========================
    public type UserBehavior = {
        appId : Core.AppId;
        behavior : Behavior;
    };

    type Behavior = {
        #view;
        #purchase;
        #play;
    };

    // User's owned games and game states
    public type UserLibrary = {
        userId : Core.UserId;
        ownedApps : [AppOwnership];
        totalPlaytime : Nat;
        lastPlayed : ?Core.Timestamp;
    };

    public type AppOwnership = {
        appId : Core.AppId;
        purchaseDate : Core.Timestamp;
        playtime : Nat;
        lastPlayed : ?Core.Timestamp;
        currentVersion : Core.Version;
    };

};
