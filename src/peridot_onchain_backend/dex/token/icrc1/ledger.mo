// src/token/icrc1/ledger.mo
import Types "types";
import Blob "mo:base/Blob";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Error "mo:base/Error";
import Buffer "mo:base/Buffer";
import TokenTypes "../TypeToken";
import Int "mo:base/Int";

module {
    public class Ledger(config : TokenTypes.TokenConfig) {
        // Account equality dan hash functions
        private func accountsEqual(a : Types.Account, b : Types.Account) : Bool {
            Principal.equal(a.owner, b.owner) and blobEqual(a.subaccount, b.subaccount)
        };

        private func accountHash(a : Types.Account) : Hash.Hash {
            let h1 = Principal.hash(a.owner);
            let h2 : Nat32 = switch (a.subaccount) {
                case null { 0 };
                case (?s) { Blob.hash(s) };
            };
            h1 +% h2;
        };

        private func blobEqual(a : ?Blob, b : ?Blob) : Bool {
            switch (a, b) {
                case (null, null) { true };
                case (?a_, ?b_) { a_ == b_ };
                case _ { false };
            };
        };

        // Ledger state
        private var totalSupply : Nat = config.initial_supply;
        private var nextTxId : Nat = 0;
        private let fee : Nat = config.transfer_fee;
        private let metadata : [(Text, TokenTypes.MetadataValue)] = config.metadata;
        private let balances = HashMap.HashMap<Types.Account, Nat>(
            16,
            accountsEqual,
            accountHash,
        );
        private let transactions = Buffer.Buffer<Types.TransferArgs>(100);

        // Initialize ledger with initial supply
        do {
            balances.put(config.minting_account, config.initial_supply);
        };

        // Getters
        public func name() : Text {
            config.name;
        };

        public func symbol() : Text {
            config.symbol;
        };

        public func decimals() : Nat8 {
            config.decimals;
        };

        public func getTotalSupply() : Nat {
            totalSupply;
        };

        public func getMetadata() : [(Text, TokenTypes.MetadataValue)] {
            metadata;
        };

        public func getFee() : Nat {
            fee;
        };

        public func getMintingAccount() : ?Types.Account {
            ?config.minting_account;
        };

        public func getBalance(account : Types.Account) : Nat {
            switch (balances.get(account)) {
                case null { 0 };
                case (?balance) { balance };
            };
        };

        // Core transfer function
        public func transfer(args : Types.TransferArgs) : Types.TransferResult {
            // Deduct fee if specified
            let transferFee = Option.get(args.fee, fee);
            if (transferFee != fee) {
                return #Err(#BadFee { expected_fee = fee });
            };

            // Check from_account, must be a valid account with owner as Principal
            let fromAccount : Types.Account = {
                owner = args.to.owner; // Tetap gunakan Principal dari args.to
                subaccount = args.from_subaccount;
            };

            let fromBalance = getBalance(fromAccount);
            if (fromBalance < args.amount + transferFee) {
                return #Err(#InsufficientFunds { balance = fromBalance });
            };

            // Check for created_at_time validity
            switch (args.created_at_time) {
                case (?created_time) {
                    let now = Nat64.fromNat(Int.abs(Time.now()));
                    // Transaction too old (5 minutes)
                    if (created_time + 300_000_000_000 < now) {
                        return #Err(#TooOld);
                    };
                    // Transaction from future
                    if (created_time > now + 300_000_000_000) {
                        return #Err(#CreatedInFuture { ledger_time = now });
                    };
                };
                case null { /* No time check needed */ };
            };

            // Execute transfer
            let newFromBalance = fromBalance - args.amount - transferFee;
            balances.put(fromAccount, newFromBalance);

            let toBalance = getBalance(args.to);
            balances.put(args.to, toBalance + args.amount);

            // Record transaction
            transactions.add(args);
            let txIndex = nextTxId;
            nextTxId += 1;

            #Ok(txIndex);
        };

        public func getSupportedStandards() : [Types.StandardRecord] {
            [{ name = "ICRC-1"; url = "https://github.com/dfinity/ICRC-1" }];
        };
    };
};
