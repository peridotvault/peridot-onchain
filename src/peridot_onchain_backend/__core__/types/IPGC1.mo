// Types.mo — PGC-1 Core Types (v1.1.0)
// Gunakan: import T "./Types";

import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Time "mo:base/Time";

module IPGC1 {
  public type Timestamp = Time.Time;

  public type Platform = {
    #web;
    #windows;
    #macos;
    #linux;
    #android;
    #ios;
    #other;
  };

  public type Manifest = {
    version : Text;
    sizeBytes : Nat64;
    checksum : Blob; // bytes32 ≈ 32-byte Blob
    createdAt : Timestamp; // timestamp in nanoseconds
  };

  public type Hardware = {
    processor : Text;
    graphics : Text;
    memoryMB : Nat32;
    storageMB : Nat32;
    additionalNotes : Text;
  };

  // Payment Token Info
  public type PaymentToken = {
    canisterId : Principal;
    symbol : Text; // e.g., "ICP", "ckUSDT", "ckBTC"
    decimals : Nat8; // e.g., 8 for ICP, 6 for USDT
  };

  public type Purchase = {
    time : Timestamp;
    amount : Nat64; // dalam smallest unit (e.g., e8s untuk ICP)
    tokenUsed : Principal; // canister ID token yang digunakan
  };

  // ========== INIT ARGS ==========
  public type init = {
    initGameId : Text;
    initName : Text;
    initDescription : Text;
    initMetadataURI : Text;
    initPrice : Nat64; // 🔹 0 = FREE game
    initMaxSupply : Nat64; // 🔹 0 = unlimited
    initTokenCanister : Principal;
  };

  // ========== STABLE STATE ==========
  public type StableState = {
    gameId : Text;
    maxSupply : Nat64;
    name : Text;
    description : Text;
    published : Bool;
    price : Nat64; // 🔹 0 = FREE

    // Pembelian
    purchases : HashMap.HashMap<Principal, Purchase>;
    totalPurchased : Nat64;
    lifetimePurchases : Nat64;
    lifetimeRevenue : Nat64;
    refundableBalance : Nat64;
    withdrawnBalance : Nat64; // 🔹 NEW: Total yang sudah di-withdraw

    // Build & Hardware
    manifests : HashMap.HashMap<Platform, [Manifest]>;
    liveManifestIndex : HashMap.HashMap<Platform, Nat64>;
    hardware : HashMap.HashMap<Platform, Hardware>;
    metadataURI : Text;

    owner : Principal;
    vaultCanister : Principal; // 🔹 NEW: PeridotVault untuk revenue sharing
  };

  // ========== RESULT TYPES ==========
  public type Result<Ok, Err> = { #ok : Ok; #err : Err };

  // Purchase result dengan status jelas
  public type PurchaseResult = {
    #success : { txIndex : Nat; timestamp : Timestamp };
    #alreadyOwned;
    #notPublished;
    #soldOut;
    #paymentFailed : Text;
    #insufficientAllowance;
  };

  // Refund result
  public type RefundResult = {
    #success : { amount : Nat64 };
    #notOwned;
    #windowClosed;
    #transferFailed : Text;
  };

  // Withdraw result dengan vault share info
  public type WithdrawResult = {
    #success : { amount : Nat; vaultShare : Nat };
    #unauthorized;
    #noBalance;
    #transferFailed : Text;
  };
};
