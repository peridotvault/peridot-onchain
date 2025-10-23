import Core "../../_core_/Core";
import Principal "mo:base/Principal";
import TokenLedger "./../../_core_/shared/TokenLedger";

module PaymentService {
  type Account = TokenLedger.Account__1;
  type Ledger = TokenLedger.Self;
  type ApiResponse<T> = Core.ApiResponse<T>;

  // Helper: buat akun dari Principal
  public func accountOf(principal : Principal) : Account {
    { owner = principal; subaccount = null };
  };

  // Merchant account (biasanya owner dari game/canister)
  public func merchantAccount(merchant : Principal) : Account {
    { owner = merchant; subaccount = null };
  };

  // Service utama: lakukan pembayaran dari user ke merchant
  public func pay(
    tokenLedger : Ledger,
    payer : Principal, // user yang membayar
    merchant : Principal, // penerima dana
    spender : Principal, // canister yang diizinkan menarik dana (biasanya diri sendiri)
    amount : Nat, // jumlah yang harus dibayar
  ) : async ApiResponse<Nat> {
    // mengembalikan txIndex jika sukses
    let userAccount : Account = accountOf(payer);
    let spenderAccount : Account = accountOf(spender);

    // 1. Cek allowance: apakah user sudah approve canister?
    let allowanceRes = await tokenLedger.icrc2_allowance({
      account = userAccount;
      spender = spenderAccount;
    });

    if (allowanceRes.allowance < amount) {
      return #err(#NotAuthorized("Insufficient allowance; please approve the spender first"));
    };

    // 2. Lakukan transfer_from: user → merchant, via spender
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
        // Kamu bisa memetakan error ledger ke error kustom jika perlu
        return #err(#StorageError("Payment transfer failed: " # debug_show e));
      };
      case (#Ok txIndex) {
        return #ok(txIndex);
      };
    };
  };
};

// Di dalam buyGame, bagian pembayaran (setelah validasi harga & NFT mint):
// let paymentResult = await PaymentService.pay(
//   tokenLedger = tokenLedgerService,
//   payer = caller,
//   merchant = merchantPrincipal,
//   spender = spenderPrincipal,
//   amount = price,
// );

// switch (paymentResult) {
//   case (#err e) return #err(e);
//   case (#ok txIndex) {
//     // Lanjutkan buat Purchase record seperti sebelumnya...
//     let newPurchase : PurchaseType = {
//       userId = caller;
//       gameId = gameId;
//       amount = price;
//       purchasedAt = Time.now();
//       txIndex = ?txIndex;
//       memo = null;
//     };
//     // ... simpan ke `purchases`
//     return #ok(newPurchase);
//   };
// };
