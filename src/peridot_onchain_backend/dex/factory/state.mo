// src/factory/state.mo
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import TokenTypes "../token/TypeToken";

module {
    // Canister management types
    public type CanisterSettings = {
        controllers : ?[Principal];
        compute_allocation : ?Nat;
        memory_allocation : ?Nat;
        freezing_threshold : ?Nat;
    };

    public type InstallMode = {
        #install;
        #reinstall;
        #upgrade;
    };

    // Token information
    public type TokenInfo = {
        metadata : TokenTypes.TokenMetadata;
        created_at : Time.Time;
        creator : Principal;
    };

    // Token information for stable storage
    public type StableTokenInfo = {
        id : Principal;
        metadata : TokenTypes.TokenMetadata;
        created_at : Time.Time;
        creator : Principal;
    };

    // Public token information (exposed via queries)
    public type PublicTokenInfo = {
        id : Principal;
        metadata : TokenTypes.TokenMetadata;
        created_at : Time.Time;
    };
};
