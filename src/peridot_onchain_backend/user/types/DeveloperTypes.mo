import Text "mo:base/Text";
import Core "./../../core/Core";

module {
    public type AnnouncementId = Text;
    //  =====================================
    //  =====================================
    // Developer ============================
    public type Developer = {
        developer_website : Text;
        developer_bio : Text;
        total_follower : Nat;
        joined_date : Core.Timestamp;
        announcements : ?[AnnouncementId];
    };

    //  =====================================
    //  =====================================
    // Developer Follower ===================
    public type DeveloperFollow = {
        developer_principal_id : Core.UserPrincipal;
        follower_principal_id : Core.UserPrincipal;
        created_at : Core.Timestamp;
    };

    //  =====================================
    //  =====================================
    // Announcements ==============
    public type Announcement = {
        id : AnnouncementId;
        developer_principal_id : Core.UserPrincipal;
        cover_image : Text;
        headline : Text;
        content : Text;
        total_likes : Nat;
        total_dislikes : Nat;
        created_at : Core.Timestamp;
    };

    // Separated interaction records
    public type AnnouncementInteraction = {
        announcement_id : AnnouncementId;
        user_principal_id : Core.UserPrincipal;
        interaction_type : InteractionType;
        created_at : Core.Timestamp;
    };

    public type InteractionType = {
        #like;
        #dislike;
        #comment : Text;
    };

    // // Announcement Comment =================
    // public type AnnouncementComment = {
    //     user_principal_id : Core.UserPrincipal;
    //     comment : Text;
    //     created_at : Core.Timestamp;
    // };

    // // Announcement Like ====================
    // public type AnnouncementLike = {
    //     user_principal_id : Core.UserPrincipal;
    // };

    // // Announcement Dislike =================
    // public type AnnouncementDislike = {
    //     user_principal_id : Core.UserPrincipal;
    // };
};
