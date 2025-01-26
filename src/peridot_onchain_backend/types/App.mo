import Text "mo:base/Text";
import Float "mo:base/Float";
import Core "./Core";

module {

    //  =====================================
    //  =====================================
    // App ==================================
    public type App = {
        app_id : Core.AppId;
        developer_principal_id : Core.UserPrincipal;
        title : Text;
        description : Text;
        cover_image : Text;
        price : Float;
        required_age : Int;
        release_date : Core.Timestamp;
        status : Core.Status;
        created_at : Core.Timestamp;
        category : ?Core.Category;
        game_tags : ?[Core.Tag];
        manifests : [Manifest];
        system_requirements : SystemRequirements;
        game_ratings : ?[GameRating];
    };

    // Manifests ============================
    public type Manifest = {
        version : Text;
        size : Float;
        bucket : Text;
        base_path : Text;
        checksum : Text;
        content : Text;
        created_at : Core.Timestamp;
    };

    // System Requirements ==================
    public type SystemRequirements = {
        os : [OS];
        processor : Text;
        memory : Int;
        storage : Int;
        graphics : Text;
        additionalNotes : ?Text;
    };

    // OS ===================================
    public type OS = {
        #windows;
        #macos;
        #linux;
        #browser;
    };

    // Game Ratings =========================
    public type GameRating = {
        user_principal_id : Core.UserPrincipal;
        rating : Int;
        comment : Text;
        created_at : Core.Timestamp;
    };

};
