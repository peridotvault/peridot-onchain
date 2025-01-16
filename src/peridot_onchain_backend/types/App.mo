import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Core "./Core";

module {
    public type Category = Text;
    public type TagGroup = Text;
    public type Tag = Text;

    public type App = {
        appId : Core.AppId;
        developer : Principal;
        title : Text;
        description : Text;
        coverImage : Text;
        price : Nat;
        category : ?Category;
        tag : ?[Tag];
        releaseDate : Core.Timestamp;
        lastUpdated : Core.Timestamp;
        currentVersion : Core.Version;
        status : AppStatus;
        storageInfo : StorageInfo;
        systemRequirements : SystemRequirements;
        comment : ?[Comment];
        languages : [Core.Language];
    };

    public type SystemRequirements = {
        os : [OS];
        processor : Text;
        memory : Nat;
        storage : Nat;
        graphics : Text;
        additionalNotes : ?Text;
    };

    public type OS = {
        #windows;
        #macos;
        #linux;
        #browser;
    };

    type Comment = {
        username : Text;
        comment : Text;
        rating : Nat;
    };

    // App Status
    public type AppStatus = {
        #active;
        #beta;
        #development;
        #maintenance;
        #inactive;
        #comingSoon;
        #suspended;
    };

    // Storage
    public type StorageInfo = {
        wasabiBucket : Text;
        basePath : Text;
        currentManifest : FileManifest;
        previousManifests : [FileManifest];
    };

    public type FileManifest = {
        version : Core.Version;
        files : [GameFile];
        totalSize : Nat;
        requiredSpace : Nat;
        checksum : Text;
        uploadDate : Core.Timestamp;
    };

    public type GameFile = {
        path : Text;
        fileName : Text;
        size : Nat;
        checksum : Text;
        isRequired : Bool;
    };

    // Category
    public let categoryName : [Category] = [
        // Core Game Types
        "Action",
        "Action RPG",
        "Adventure",
        "Arcade",
        "Battle Royale",
        "Beat 'em up",
        "Card Game",
        "Casual",

        // Role Playing
        "MMORPG",
        "RPG",
        "Tactical RPG",
        "Visual Novel",

        // Strategy & Management
        "City Builder",
        "Grand Strategy",
        "MOBA",
        "RTS",
        "Strategy",
        "Tower Defense",
        "Tycoon",

        // Sports & Racing
        "Fighting",
        "Racing",
        "Sports",
        "Sports Management",

        // Simulation
        "Flight Simulator",
        "Life Simulator",
        "Mining Simulator",
        "Pet Simulator",
        "Simulation",
        "Vehicle Simulator",

        // Puzzle & Brain Training
        "Board Game",
        "Educational",
        "Logic Game",
        "Match 3",
        "Puzzle",
        "Quiz",
        "Word Game",

        // Specific Gameplay Types
        "Clicker",
        "Dungeon Crawler",
        "First Person Shooter",
        "Hidden Object",
        "Horror",
        "Idle Game",
        "Metroidvania",
        "Party Game",
        "Platform",
        "Point & Click",
        "Rhythm",
        "Roguelike",
        "Sandbox",
        "Shooter",
        "Stealth",
        "Survival",
        "Third Person Shooter",

        // Web3 Specific
        "Blockchain RPG",
        "Crypto Idle",
        "NFT Trading",
        "P2E Strategy",
        "Web3 Collectible",
    ];

    // Tags
    public let tagGroups : [(TagGroup, [Tag])] = [
        (
            "Gameplay",
            [
                "Multiplayer",
                "Single-player",
                "Co-op",
                "PvP",
                "PvE",
                "Open World",
                "Linear",
                "Turn-based",
                "Real-time",
                "Sandbox",
                "Story-rich",
                "Fast-paced",
                "Casual",
                "Hardcore",
                "Permadeath",
                "Choices Matter",
                "Time Management",
                "Base Building",
                "Character Customization",
                "Procedural Generation",
                "Exploration",
                "Combat-focused",
                "Stealth",
                "Survival",
                "Crafting",
                "Trading",
                "Resource Management",
                "Physics-based",
                "Level Editor",
                "New Game Plus",
                "Multiple Endings",
            ],
        ),
        (
            "Web3",
            [
                "NFT Integration",
                "Play-to-Earn",
                "Blockchain Rewards",
                "Token Economy",
                "Smart Contracts",
                "Digital Asset Trading",
                "Cross-chain",
                "DeFi Elements",
                "NFT Breeding",
                "NFT Crafting",
                "NFT Staking",
                "NFT Lending",
                "Token Governance",
                "Tokenized Items",
                "Web3 Social",
                "Decentralized Storage",
                "DAO Integration",
                "Metaverse Ready",
                "On-chain Records",
                "Crypto Rewards",
            ],
        ),
        (
            "Visual",
            [
                "2D",
                "3D",
                "Pixel Art",
                "Retro",
                "Realistic",
                "Cartoon",
                "Anime",
                "Low Poly",
                "Voxel",
                "Hand-drawn",
                "Stylized",
                "Minimalist",
                "Isometric",
                "Side View",
                "Top-down",
                "First Person",
                "Third Person",
                "VR",
                "AR",
                "Mixed Reality",
                "Cell Shaded",
                "Photo Realistic",
                "Abstract",
                "Noir",
            ],
        ),
        (
            "Technical",
            [
                "Controller Support",
                "Cloud Saves",
                "Cross-platform",
                "Mobile-friendly",
                "VR Support",
                "AR Support",
                "Ray Tracing",
                "DLSS Support",
                "HDR Support",
                "Ultrawide Support",
                "High FPS",
                "Cross-save",
                "Mod Support",
                "Custom Servers",
                "LAN Support",
                "Voice Chat",
                "Text Chat",
                "Gamepad Recommended",
                "Mouse & Keyboard",
                "Touch Screen",
                "Motion Controls",
                "Local Co-op",
                "Remote Play",
                "Steam Deck Verified",
                "Low Spec Friendly",
            ],
        ),
        (
            "Social",
            [
                "Guild System",
                "Team-based",
                "Community Events",
                "Tournaments",
                "Competitive",
                "Casual",
                "Clans",
                "Social Hub",
                "Friend System",
                "Party System",
                "Trading System",
                "Leaderboards",
                "Achievements",
                "Rankings",
                "Matchmaking",
                "Chat Rooms",
                "Community Market",
                "User Generated Content",
                "Streaming Integration",
                "Social Media Integration",
                "Esports Ready",
                "Spectator Mode",
                "Community Challenges",
                "Player Housing",
            ],
        ),
        (
            "Monetization",
            [
                "Free-to-Play",
                "Premium",
                "NFT Marketplace",
                "Token Rewards",
                "Battle Pass",
                "Season Pass",
                "Subscription",
                "Buy to Play",
                "Free Demo",
                "DLC Available",
                "Microtransactions",
                "Cosmetic Items",
                "Loot Boxes",
                "In-game Currency",
                "Trading Cards",
                "Premium Currency",
                "Supporter Pack",
                "Founder's Pack",
                "Early Access",
                "Referral Rewards",
            ],
        ),
        (
            "Setting",
            [
                "Fantasy",
                "Sci-fi",
                "Modern",
                "Historical",
                "Post-apocalyptic",
                "Cyberpunk",
                "Steampunk",
                "Medieval",
                "Western",
                "Horror",
                "Military",
                "Space",
                "Urban",
                "Prehistoric",
                "Alternate History",
                "Mythology",
                "Superhero",
                "Lovecraftian",
                "Dieselpunk",
                "Gothic",
                "Tropical",
                "Arctic",
                "Desert",
                "Underwater",
            ],
        ),
        (
            "Content",
            [
                "Family Friendly",
                "Gore",
                "Violent",
                "Adult Content",
                "Blood",
                "Drug Reference",
                "Strong Language",
                "Sexual Content",
                "Nudity",
                "Gambling",
                "Mature Themes",
                "Controversial",
                "Political",
                "Religious",
                "Educational",
                "Documentary",
                "PEGI 3",
                "PEGI 7",
                "PEGI 12",
                "PEGI 16",
                "PEGI 18",
                "ESRB Everyone",
                "ESRB Teen",
                "ESRB Mature",
            ],
        ),
    ];

};
