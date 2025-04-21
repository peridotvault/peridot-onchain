// src/token/icrc1/types.mo
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Time "mo:base/Time";

module {
    // Standard ICRC-1 Account
    public type Account = {
        owner : Principal;
        subaccount : ?Blob;
    };

    // Transfer Arguments
    public type TransferArgs = {
        from_subaccount : ?Blob;
        to : Account;
        amount : Nat;
        fee : ?Nat;
        memo : ?Blob;
        created_at_time : ?Nat64;
    };

    // Transfer Result
    public type TransferResult = {
        #Ok : Nat;
        #Err : TransferError;
    };

    // Transfer Error Types
    public type TransferError = {
        #BadFee : { expected_fee : Nat };
        #BadBurn : { min_burn_amount : Nat };
        #InsufficientFunds : { balance : Nat };
        #TooOld;
        #CreatedInFuture : { ledger_time : Nat64 };
        #Duplicate : { duplicate_of : Nat };
        #TemporarilyUnavailable;
        #GenericError : { error_code : Nat; message : Text };
    };

    // ICRC-1 Token Interface
    public type ICRC1Interface = actor {
        icrc1_name : () -> async Text;
        icrc1_symbol : () -> async Text;
        icrc1_decimals : () -> async Nat8;
        icrc1_total_supply : () -> async Nat;
        icrc1_fee : () -> async Nat;
        icrc1_metadata : () -> async [(Text, MetadataValue)];
        icrc1_minting_account : () -> async ?Account;
        icrc1_balance_of : (Account) -> async Nat;
        icrc1_transfer : (TransferArgs) -> async TransferResult;
        icrc1_supported_standards : () -> async [StandardRecord];
    };

    // Metadata value type
    public type MetadataValue = {
        #Text : Text;
        #Blob : Blob;
        #Nat : Nat;
        #Int : Int;
    };

    // Standard record
    public type StandardRecord = {
        name : Text;
        url : Text;
    };
};
