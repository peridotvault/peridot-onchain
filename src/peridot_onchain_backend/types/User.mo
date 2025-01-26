import Text "mo:base/Text";
import Core "./Core";
import Developer "./Developer";

module {
    public type Username = Text;

    //  =====================================
    //  =====================================
    // User =================================
    public type User = {
        username : Username;
        display_name : Text;
        email : Text;
        image_url : ?Text;
        total_playtime : ?Int;
        created_at : Core.Timestamp;
        user_demographics : UserDemographic;
        user_interactions : ?[UserInteraction];
        user_libraries : ?[UserLibrary];
        developer : ?Developer.Developer;
    };

    // User Demographics =========================
    public type UserDemographic = {
        birth_date : Core.Timestamp;
        gender : Gender;
        country : Core.Country;
    };

    public type Gender = {
        #male;
        #female;
        #other;
    };

    // User Interactions =========================
    public type UserInteraction = {
        app_id : Core.UserPrincipal;
        interaction : Interaction;
        created_at : Core.Timestamp;
    };

    public type Interaction = {
        #view;
        #purchase;
        #play;
    };

    // User Library =========================
    public type UserLibrary = {
        app_id : Core.AppId;
        playtime_minute : Int;
        lastPlayed : ?Core.Timestamp;
        current_version : Core.Version;
        created_at : Core.Timestamp;
    };

    //  =====================================
    //  =====================================
    // User Friends =========================
    public type UserFriend = {
        user1_principal_id : Core.UserPrincipal;
        user2_principal_id : Core.UserPrincipal;
        status : Core.Status;
        created_at : Core.Timestamp;
    };

};
