// src/token/main.mo
import Types "TypeToken";
import ICRC1Types "icrc1/types";
import ICRC1Ledger "icrc1/ledger";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Nat8 "mo:base/Nat8";
import Error "mo:base/Error";

actor class Token(config : Types.TokenConfig) = this {
    // Initialize ICRC-1 ledger
    private let ledger = ICRC1Ledger.Ledger(config);

    // Helper functions for metadata extraction
    private func getLogoFromMetadata(metadata : [(Text, Types.MetadataValue)]) : ?Text {
        for ((key, value) in metadata.vals()) {
            if (key == "logo") {
                switch (value) {
                    case (#Text(text)) { return ?text };
                    case (_) {};
                };
            };
        };
        null;
    };

    private func getDescriptionFromMetadata(metadata : [(Text, Types.MetadataValue)]) : ?Text {
        for ((key, value) in metadata.vals()) {
            if (key == "description") {
                switch (value) {
                    case (#Text(text)) { return ?text };
                    case (_) {};
                };
            };
        };
        null;
    };

    // Metadata
    private let tokenMetadata : Types.TokenMetadata = {
        name = config.name;
        symbol = config.symbol;
        decimals = config.decimals;
        fee = config.transfer_fee;
        logo = getLogoFromMetadata(config.metadata);
        description = getDescriptionFromMetadata(config.metadata);
        created_at = Time.now();
        creator = config.minting_account.owner;
    };

    // ICRC-1 Standard Interface
    public query func icrc1_name() : async Text {
        ledger.name();
    };

    public query func icrc1_symbol() : async Text {
        ledger.symbol();
    };

    public query func icrc1_decimals() : async Nat8 {
        ledger.decimals();
    };

    public query func icrc1_total_supply() : async Nat {
        ledger.getTotalSupply();
    };

    public query func icrc1_fee() : async Nat {
        ledger.getFee();
    };

    public query func icrc1_metadata() : async [(Text, ICRC1Types.MetadataValue)] {
        ledger.getMetadata();
    };

    public query func icrc1_minting_account() : async ?ICRC1Types.Account {
        ledger.getMintingAccount();
    };

    public query func icrc1_balance_of(account : ICRC1Types.Account) : async Nat {
        ledger.getBalance(account);
    };

    public shared (msg) func icrc1_transfer(args : ICRC1Types.TransferArgs) : async ICRC1Types.TransferResult {
        // Set from account if not specified
        let actualArgs = {
            from_subaccount = args.from_subaccount;
            to = args.to;
            amount = args.amount;
            fee = args.fee;
            memo = args.memo;
            created_at_time = args.created_at_time;
        };

        ledger.transfer(actualArgs);
    };

    public query func icrc1_supported_standards() : async [ICRC1Types.StandardRecord] {
        ledger.getSupportedStandards();
    };

    // Persiapan untuk ICRC-2 (dapat diimplementasikan nanti)
    // public shared(msg) func icrc2_approve(...) : async {...}

    // Fungsi untuk mendapatkan metadata token
    public query func getTokenMetadata() : async Types.TokenMetadata {
        tokenMetadata;
    };
};
