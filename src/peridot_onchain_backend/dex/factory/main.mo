// src/factory/main.mo
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import TrieMap "mo:base/TrieMap";
import Iter "mo:base/Iter";
import TokenTypes "../token/TypeToken";
import ICRC1Types "../token/icrc1/types";
import State "state";
import Cycles "mo:base/ExperimentalCycles";

actor class Factory(owner_ : Principal) = self {
    // State untuk menyimpan data factory
    private stable var stableTokens : [State.StableTokenInfo] = [];
    private stable var nextTokenId : Nat = 0;
    private var owner : Principal = owner_;
    private var tokens = TrieMap.TrieMap<Principal, State.TokenInfo>(
        Principal.equal,
        Principal.hash,
    );

    // Interface untuk Management Canister
    private type Management = actor {
        create_canister : { settings : ?State.CanisterSettings } -> async {
            canister_id : Principal;
        };
        install_code : {
            mode : State.InstallMode;
            canister_id : Principal;
            wasm_module : Blob;
            arg : Blob;
        } -> async ();
        update_settings : {
            canister_id : Principal;
            settings : State.CanisterSettings;
        } -> async ();
    };

    private let IC : Management = actor "aaaaa-aa";

    // Upgrade hook untuk memigrasikan state
    system func preupgrade() {
        stableTokens := Array.map<(Principal, State.TokenInfo), State.StableTokenInfo>(
            Iter.toArray(tokens.entries()),
            func((id, info)) : State.StableTokenInfo {
                {
                    id = id;
                    metadata = info.metadata;
                    created_at = info.created_at;
                    creator = info.creator;
                };
            },
        );
    };

    system func postupgrade() {
        for (token in stableTokens.vals()) {
            tokens.put(
                token.id,
                {
                    metadata = token.metadata;
                    created_at = token.created_at;
                    creator = token.creator;
                },
            );
        };
        stableTokens := [];
    };

    // Fungsi untuk mendapatkan Principal ID dari actor
    private func getFactoryPrincipal() : Principal {
        Principal.fromActor(self);
    };

    // Fungsi untuk membuat token ICRC-1 baru
    public shared (msg) func createToken(
        config : {
            name : Text;
            symbol : Text;
            decimals : Nat8;
            initial_supply : Nat;
            transfer_fee : Nat;
            metadata : [(Text, TokenTypes.MetadataValue)];
        }
    ) : async Result.Result<Principal, Text> {
        // Hanya owner atau approved creators yang dapat membuat token
        if (not Principal.equal(msg.caller, owner)) {
            return #err("Unauthorized: Only the owner can create tokens");
        };

        // Tambahkan cycles untuk canister baru
        let requiredCycles = 1_000_000_000_000; // 1T cycles
        if (Cycles.available() < requiredCycles) {
            return #err("Insufficient cycles to create a new token");
        };
        Cycles.add(requiredCycles);

        try {
            // 1. Buat canister baru
            let settings = {
                controllers = ?[owner, msg.caller];
                compute_allocation = ?(0);
                memory_allocation = ?(0);
                freezing_threshold = ?(0);
            };

            let { canister_id } = await IC.create_canister({
                settings = ?settings;
            });

            // 2. Siapkan konfigurasi token
            let tokenConfig : TokenTypes.TokenConfig = {
                name = config.name;
                symbol = config.symbol;
                decimals = config.decimals;
                initial_supply = config.initial_supply;
                transfer_fee = config.transfer_fee;
                minting_account = { owner = msg.caller; subaccount = null };
                metadata = Array.append(
                    config.metadata,
                    [
                        ("factory", #Text(Principal.toText(getFactoryPrincipal()))),
                        ("created_at", #Int(Time.now())),
                        ("creator", #Text(Principal.toText(msg.caller))),
                    ],
                );
            };

            // 3. Buat dan install kode token (implementation sebenarnya akan membutuhkan Wasm)
            // Catatan: Dalam implementasi nyata, wasm_module harus berisi bytecode ICRC-1 token
            let wasm_module = Blob.fromArray([]); // Placeholder untuk wasm bytecode
            let arg = Blob.fromArray([]); // Placeholder untuk encoded args (gunakan Candid)

            await IC.install_code({
                mode = #install;
                canister_id = canister_id;
                wasm_module = wasm_module;
                arg = arg;
            });

            // 4. Catat token baru
            let tokenInfo : State.TokenInfo = {
                metadata = {
                    name = config.name;
                    symbol = config.symbol;
                    decimals = config.decimals;
                    fee = config.transfer_fee;
                    logo = getLogoFromMetadata(config.metadata);
                    description = getDescriptionFromMetadata(config.metadata);
                    created_at = Time.now();
                    creator = msg.caller;
                };
                created_at = Time.now();
                creator = msg.caller;
            };

            tokens.put(canister_id, tokenInfo);
            nextTokenId += 1;

            #ok(canister_id);
        } catch (err) {
            #err("Failed to create token: " # Error.message(err));
        };
    };

    // Helper functions untuk metadata extraction
    private func getLogoFromMetadata(metadata : [(Text, TokenTypes.MetadataValue)]) : ?Text {
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

    private func getDescriptionFromMetadata(metadata : [(Text, TokenTypes.MetadataValue)]) : ?Text {
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

    // Fungsi query untuk mendapatkan daftar token
    public query func listTokens() : async [State.PublicTokenInfo] {
        Array.map<(Principal, State.TokenInfo), State.PublicTokenInfo>(
            Iter.toArray(tokens.entries()),
            func((id, info)) : State.PublicTokenInfo {
                {
                    id = id;
                    metadata = info.metadata;
                    created_at = info.created_at;
                };
            },
        );
    };

    // Fungsi untuk mendapatkan informasi token spesifik
    public query func getToken(id : Principal) : async ?State.PublicTokenInfo {
        switch (tokens.get(id)) {
            case (null) { null };
            case (?info) {
                ?{
                    id = id;
                    metadata = info.metadata;
                    created_at = info.created_at;
                };
            };
        };
    };

    // Fungsi administratif
    public shared (msg) func transferOwnership(newOwner : Principal) : async Result.Result<(), Text> {
        if (not Principal.equal(msg.caller, owner)) {
            return #err("Unauthorized: Only the owner can transfer ownership");
        };

        owner := newOwner;
        #ok();
    };

    public query func getOwner() : async Principal {
        owner;
    };
};
