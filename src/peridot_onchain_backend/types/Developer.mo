import Text "mo:base/Text";
import Int "mo:base/Int";
import Core "./Core";

module {
    //  =====================================
    //  =====================================
    // Developer ============================
    public type Developer = {
        developer_website : Text;
        developer_bio : Text;
        total_follower : Int;
        joined_date : Core.Timestamp;
        developer_followers : ?[DeveloperFollower];
        developer_announcement : ?[DeveloperAnnouncement];
    };

    //  =====================================
    //  =====================================
    // Developer Follower ===================
    public type DeveloperFollower = {
        user_principal_id : Core.UserPrincipal;
        created_at : Core.Timestamp;
    };

    //  =====================================
    //  =====================================
    // Developer Announcements ==============
    public type DeveloperAnnouncement = {
        cover_image : Text;
        headline : Text;
        content : Text;
        total_like : Int;
        total_dislike : Int;
        created_at : Core.Timestamp;
        announcement_comments : ?[AnnouncementComment];
        announcement_likes : ?[AnnouncementLike];
        announcement_dislikes : ?[AnnouncementDislike];
    };

    // Announcement Comment =================
    public type AnnouncementComment = {
        user_principal_id : Core.UserPrincipal;
        comment : Text;
        created_at : Core.Timestamp;
    };

    // Announcement Like ====================
    public type AnnouncementLike = {
        user_principal_id : Core.UserPrincipal;
    };

    // Announcement Dislike =================
    public type AnnouncementDislike = {
        user_principal_id : Core.UserPrincipal;
    };
};
