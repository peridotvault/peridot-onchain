// PaymentService.mo - Fixed Version with Clear Return Types
import Core "../Core";
import Principal "mo:base/Principal";
import TokenLedger "./../shared/TokenLedger";

module PaymentService {
  type Account = TokenLedger.Account__1;
  type Ledger = TokenLedger.Self;
  type ApiResponse<T> = Core.ApiResponse<T>;

  // 🔹 Error types yang lebih spesifik
  public type PaymentError = {
    #InsufficientAllowance : { required : Nat; available : Nat };
    #TransferFailed : Text;
    #InsufficientBalance;
    #InvalidAmount;
    #GenericError : Text;
  };

  public type PaymentResult = {
    #ok : Nat; // txIndex
    #err : PaymentError;
  };

  // Helper: buat akun dari Principal
  public func accountOf(principal : Principal) : Account {
    { owner = principal; subaccount = null };
  };

  // Merchant account (biasanya owner dari game/canister)
  public func merchantAccount(merchant : Principal) : Account {
    { owner = merchant; subaccount = null };
  };

  // 🔹 Service utama: lakukan pembayaran dari user ke merchant
  public func pay(
    tokenLedger : Ledger,
    payer : Principal, // user yang membayar
    merchant : Principal, // penerima dana
    spender : Principal, // canister yang diizinkan menarik dana
    amount : Nat, // jumlah yang harus dibayar
  ) : async ApiResponse<Nat> {
    // Validasi: amount harus > 0
    if (amount == 0) {
      return #err(#StorageError("Payment amount must be greater than 0"));
    };

    let userAccount : Account = accountOf(payer);
    let spenderAccount : Account = accountOf(spender);

    // 1️⃣ Cek allowance: apakah user sudah approve canister?
    let allowanceRes = await tokenLedger.icrc2_allowance({
      account = userAccount;
      spender = spenderAccount;
    });

    if (allowanceRes.allowance < amount) {
      return #err(
        #NotAuthorized(
          "Insufficient allowance. Required: " # debug_show amount # ", Available: " # debug_show allowanceRes.allowance
        )
      );
    };

    // 2️⃣ Lakukan transfer_from: user → merchant, via spender
    let transferRes = await tokenLedger.icrc2_transfer_from({
      from = userAccount;
      to = merchantAccount(merchant);
      amount = amount;
      fee = null;
      memo = null;
      created_at_time = null;
      spender_subaccount = null;
    });

    switch (transferRes) {
      case (#Err e) {
        // Map ledger errors ke error messages yang jelas
        let errorMsg = switch (e) {
          case (#BadFee _) "Bad fee configuration";
          case (#BadBurn _) "Bad burn amount";
          case (#InsufficientFunds _) "Insufficient funds in user account";
          case (#InsufficientAllowance _) "Insufficient allowance (should not happen)";
          case (#TooOld) "Transaction too old";
          case (#CreatedInFuture _) "Transaction created in future";
          case (#Duplicate _) "Duplicate transaction";
          case (#TemporarilyUnavailable) "Ledger temporarily unavailable";
          case (#GenericError e) "Generic error: " # e.message;
        };
        return #err(#StorageError("Payment transfer failed: " # errorMsg));
      };
      case (#Ok txIndex) {
        return #ok(txIndex);
      };
    };
  };

  // 🔹 Helper: Cek balance user
  public func checkBalance(
    tokenLedger : Ledger,
    user : Principal,
  ) : async Nat {
    await tokenLedger.icrc1_balance_of(accountOf(user));
  };

  // 🔹 Helper: Cek allowance
  public func checkAllowance(
    tokenLedger : Ledger,
    owner : Principal,
    spender : Principal,
  ) : async Nat {
    let res = await tokenLedger.icrc2_allowance({
      account = accountOf(owner);
      spender = accountOf(spender);
    });
    res.allowance;
  };

  // 🔹 NEW: Validate payment prerequisites sebelum purchase
  public func validatePayment(
    tokenLedger : Ledger,
    payer : Principal,
    spender : Principal,
    requiredAmount : Nat,
  ) : async {
    #valid;
    #insufficientBalance : { required : Nat; available : Nat };
    #insufficientAllowance : { required : Nat; available : Nat };
  } {
    // Cek balance
    let balance = await checkBalance(tokenLedger, payer);
    if (balance < requiredAmount) {
      return #insufficientBalance({
        required = requiredAmount;
        available = balance;
      });
    };

    // Cek allowance
    let allowance = await checkAllowance(tokenLedger, payer, spender);
    if (allowance < requiredAmount) {
      return #insufficientAllowance({
        required = requiredAmount;
        available = allowance;
      });
    };

    #valid;
  };
};
