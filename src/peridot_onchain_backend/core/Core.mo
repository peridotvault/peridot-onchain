import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

module {
  public let TokenLedgerCanister : Text = "b4osj-vyaaa-aaaap-an4bq-cai";
  public let Decimal : Nat = 8;
  public let PeridotAccount : Text = "qmc7g-dzjeq-haics-mfv4z-a6ypg-3m3yo-cvdrf-kyy3a-aiguy-5yvzh-kae";
  public type Timestamp = Time.Time;
  public type AppId = Nat;
  public type AnnouncementId = Nat;
  public type UserId = Principal;
  public type DeveloperId = Principal;
  public type TokenLedgerId = Principal;
  public type Version = Text;
  public type Country = Text;
  public type Language = Text;
  public type Category = Text;
  public type TagGroup = Text;
  public type Tag = Text;

  // Status =========================
  public type AppStatus = {
    #publish;
    #notPublish;
  };

  public type Status = {
    #accept;
    #pending;
    #decline;
  };

  // Country =========================
  public let country : [Country] = [
    "AFG",
    "ALB",
    "DZA",
    "AND",
    "AGO",
    "ATG",
    "ARG",
    "ARM",
    "AUS",
    "AUT",
    "AZE",
    "BHS",
    "BHR",
    "BGD",
    "BRB",
    "BLR",
    "BEL",
    "BLZ",
    "BEN",
    "BTN",
    "BOL",
    "BIH",
    "BWA",
    "BRA",
    "BRN",
    "BGR",
    "BFA",
    "BDI",
    "CPV",
    "KHM",
    "CMR",
    "CAN",
    "CAF",
    "TCD",
    "CHL",
    "CHN",
    "COL",
    "COM",
    "COG",
    "CRI",
    "HRV",
    "CUB",
    "CYP",
    "CZE",
    "COD",
    "DNK",
    "DJI",
    "DMA",
    "DOM",
    "ECU",
    "EGY",
    "SLV",
    "GNQ",
    "ERI",
    "EST",
    "SWZ",
    "ETH",
    "FJI",
    "FIN",
    "FRA",
    "GAB",
    "GMB",
    "GEO",
    "DEU",
    "GHA",
    "GRC",
    "GRD",
    "GTM",
    "GIN",
    "GNB",
    "GUY",
    "HTI",
    "HND",
    "HUN",
    "ISL",
    "IND",
    "IDN",
    "IRN",
    "IRQ",
    "IRL",
    "ISR",
    "ITA",
    "CIV",
    "JAM",
    "JPN",
    "JOR",
    "KAZ",
    "KEN",
    "KIR",
    "KWT",
    "KGZ",
    "LAO",
    "LVA",
    "LBN",
    "LSO",
    "LBR",
    "LBY",
    "LIE",
    "LTU",
    "LUX",
    "MDG",
    "MWI",
    "MYS",
    "MDV",
    "MLI",
    "MLT",
    "MHL",
    "MRT",
    "MUS",
    "MEX",
    "FSM",
    "MDA",
    "MCO",
    "MNG",
    "MNE",
    "MAR",
    "MOZ",
    "MMR",
    "NAM",
    "NRU",
    "NPL",
    "NLD",
    "NZL",
    "NIC",
    "NER",
    "NGA",
    "PRK",
    "MKD",
    "NOR",
    "OMN",
    "PAK",
    "PLW",
    "PSE",
    "PAN",
    "PNG",
    "PRY",
    "PER",
    "PHL",
    "POL",
    "PRT",
    "QAT",
    "ROU",
    "RUS",
    "RWA",
    "KNA",
    "LCA",
    "VCT",
    "WSM",
    "SMR",
    "STP",
    "SAU",
    "SEN",
    "SRB",
    "SYC",
    "SLE",
    "SGP",
    "SVK",
    "SVN",
    "SLB",
    "SOM",
    "ZAF",
    "KOR",
    "SSD",
    "ESP",
    "LKA",
    "SDN",
    "SUR",
    "SWE",
    "CHE",
    "SYR",
    "TJK",
    "TZA",
    "THA",
    "TLS",
    "TGO",
    "TON",
    "TTO",
    "TUN",
    "TUR",
    "TKM",
    "TUV",
    "UGA",
    "UKR",
    "ARE",
    "GBR",
    "USA",
    "URY",
    "UZB",
    "VUT",
    "VAT",
    "VEN",
    "VNM",
    "YEM",
    "ZMB",
    "ZWE",
  ];

  // Language =========================
  public let language : [Language] = [
    "AAR", // Afar
    "ABK", // Abkhazian
    "AFR", // Afrikaans
    "AKA", // Akan
    "ALB", // Albanian
    "AMH", // Amharic
    "ARA", // Arabic
    "ARG", // Aragonese
    "ARM", // Armenian
    "ASM", // Assamese
    "AVA", // Avaric
    "AVE", // Avestan
    "AYM", // Aymara
    "AZE", // Azerbaijani
    "BAK", // Bashkir
    "BAM", // Bambara
    "BAS", // Basque
    "BEL", // Belarusian
    "BEN", // Bengali
    "BIH", // Bihari languages
    "BIS", // Bislama
    "BOD", // Tibetan
    "BOS", // Bosnian
    "BRE", // Breton
    "BUL", // Bulgarian
    "CAT", // Catalan
    "CES", // Czech
    "CHA", // Chamorro
    "CHE", // Chechen
    "CHI", // Chinese
    "CHV", // Chuvash
    "COR", // Cornish
    "COS", // Corsican
    "CRE", // Cree
    "CYM", // Welsh
    "DAN", // Danish
    "DEU", // German
    "DIV", // Divehi
    "DZO", // Dzongkha
    "ELL", // Greek
    "ENG", // English
    "EPO", // Esperanto
    "EST", // Estonian
    "EUS", // Basque
    "EWE", // Ewe
    "FAO", // Faroese
    "FAS", // Persian
    "FIJ", // Fijian
    "FIN", // Finnish
    "FRA", // French
    "FRY", // Western Frisian
    "FUL", // Fulah
    "GLA", // Gaelic
    "GLE", // Irish
    "GLG", // Galician
    "GLV", // Manx
    "GRN", // Guarani
    "GUJ", // Gujarati
    "HAT", // Haitian
    "HAU", // Hausa
    "HEB", // Hebrew
    "HER", // Herero
    "HIN", // Hindi
    "HMO", // Hiri Motu
    "HRV", // Croatian
    "HUN", // Hungarian
    "HYE", // Armenian
    "IBO", // Igbo
    "IDO", // Ido
    "III", // Sichuan Yi
    "IKU", // Inuktitut
    "ILE", // Interlingue
    "INA", // Interlingua
    "IND", // Indonesian
    "IPK", // Inupiaq
    "ISL", // Icelandic
    "ITA", // Italian
    "JAV", // Javanese
    "JPN", // Japanese
    "KAL", // Kalaallisut
    "KAN", // Kannada
    "KAS", // Kashmiri
    "KAT", // Georgian
    "KAU", // Kanuri
    "KAZ", // Kazakh
    "KHM", // Central Khmer
    "KIK", // Kikuyu
    "KIN", // Kinyarwanda
    "KIR", // Kirghiz
    "KOM", // Komi
    "KON", // Kongo
    "KOR", // Korean
    "KUA", // Kuanyama
    "KUR", // Kurdish
    "LAO", // Lao
    "LAT", // Latin
    "LAV", // Latvian
    "LIM", // Limburgan
    "LIN", // Lingala
    "LIT", // Lithuanian
    "LTZ", // Luxembourgish
    "LUB", // Luba-Katanga
    "LUG", // Ganda
    "MAH", // Marshallese
    "MAL", // Malayalam
    "MAR", // Marathi
    "MKD", // Macedonian
    "MLG", // Malagasy
    "MLT", // Maltese
    "MON", // Mongolian
    "MRI", // Maori
    "MSA", // Malay
    "MYA", // Burmese
    "NAU", // Nauru
    "NAV", // Navajo
    "NBL", // South Ndebele
    "NDE", // North Ndebele
    "NDO", // Ndonga
    "NEP", // Nepali
    "NLD", // Dutch
    "NNO", // Norwegian Nynorsk
    "NOB", // Norwegian Bokmål
    "NOR", // Norwegian
    "NYA", // Nyanja
    "OCI", // Occitan
    "OJI", // Ojibwa
    "ORI", // Oriya
    "ORM", // Oromo
    "OSS", // Ossetian
    "PAN", // Panjabi
    "PLI", // Pali
    "POL", // Polish
    "POR", // Portuguese
    "PUS", // Pushto
    "QUE", // Quechua
    "ROH", // Romansh
    "RON", // Romanian
    "RUN", // Rundi
    "RUS", // Russian
    "SAG", // Sango
    "SAN", // Sanskrit
    "SIN", // Sinhala
    "SLK", // Slovak
    "SLV", // Slovenian
    "SME", // Northern Sami
    "SMO", // Samoan
    "SNA", // Shona
    "SND", // Sindhi
    "SOM", // Somali
    "SOT", // Southern Sotho
    "SPA", // Spanish
    "SQI", // Albanian
    "SRD", // Sardinian
    "SRP", // Serbian
    "SSW", // Swati
    "SUN", // Sundanese
    "SWA", // Swahili
    "SWE", // Swedish
    "TAH", // Tahitian
    "TAM", // Tamil
    "TAT", // Tatar
    "TEL", // Telugu
    "TGK", // Tajik
    "TGL", // Tagalog
    "THA", // Thai
    "TIR", // Tigrinya
    "TON", // Tonga
    "TSN", // Tswana
    "TSO", // Tsonga
    "TUK", // Turkmen
    "TUR", // Turkish
    "TWI", // Twi
    "UIG", // Uighur
    "UKR", // Ukrainian
    "URD", // Urdu
    "UZB", // Uzbek
    "VEN", // Venda
    "VIE", // Vietnamese
    "VOL", // Volapük
    "WLN", // Walloon
    "WOL", // Wolof
    "XHO", // Xhosa
    "YID", // Yiddish
    "YOR", // Yoruba
    "ZHA", // Zhuang
    "ZHO", // Chinese
    "ZUL", // Zulu
  ];

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

  // For uniform error handling
  public type ApiResponse<T> = Result.Result<T, ApiError>;
  public type ApiError = {
    #NotFound : Text;
    #AlreadyExists : Text;
    #InvalidInput : Text;
    #StorageError : Text;
    #Unauthorized : Text;
    #InternalError : Text;
    #ValidationError : Text;
    #NotAuthorized : Text;
  };
};
