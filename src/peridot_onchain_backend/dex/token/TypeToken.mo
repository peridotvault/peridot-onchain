// src/token/types.mo
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Text "mo:base/Text";

module {
    // Type dasar untuk ICRC token
    public type TokenMetadata = {
        name : Text;
        symbol : Text;
        decimals : Nat8;
        fee : Nat;
        logo : ?Text;
        description : ?Text;
        created_at : Time.Time;
        creator : Principal;
    };

    // Type untuk konfigurasi token baru
    public type TokenConfig = {
        name : Text;
        symbol : Text;
        decimals : Nat8;
        initial_supply : Nat;
        transfer_fee : Nat;
        minting_account : Account;
        metadata : [(Text, MetadataValue)];
    };

    // Account identifier untuk ICRC-1
    public type Account = {
        owner : Principal;
        subaccount : ?Blob;
    };

    // Metadata value type
    public type MetadataValue = {
        #Text : Text;
        #Blob : Blob;
        #Nat : Nat;
        #Int : Int;
    };
};
