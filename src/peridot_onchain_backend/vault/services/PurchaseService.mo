import PeridotRegistry "canister:peridot_registry";

import Core "../../_core_/Core";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Array "mo:base/Array";
import PurchaseTypes "../types/PurchaseTypes";
import TokenLedger "./../../_core_/shared/TokenLedger";
import PGL1 "../../_core_/shared/PGL1Ledger";

module PurchaseServiceModule {
  type ApiResponse<T> = Core.ApiResponse<T>;
  type PurchaseType = PurchaseTypes.Purchase;
  type PGL1Ledger = PGL1.PGL1Ledger;

  // peridot account (peridot address)
  public func merchantAccount(self : Principal) : TokenLedger.Account__1 {
    { owner = self; subaccount = null };
  };
  func asPGL1(canisterIdTxt : Text) : PGL1.PGL1Ledger {
    actor (canisterIdTxt);
  };

  //   create
  public func buyGame(
    purchases : PurchaseTypes.PurchaseHashMap,
    gameId : Core.GameId,
    caller : Principal,
    tokenLedger : Text,
    spenderPrincipal : Core.UserId,
    merchantPrincipal : Principal,
  ) : async ApiResponse<PurchaseType> {
    let tokenLedgerService : TokenLedger.Self = actor (tokenLedger);
    let isExist = await PeridotRegistry.getGameRecordById(gameId);
    // 1) get app
    switch (isExist) {
      case (#err err) {
        return #err(err);
      };
      case (#ok game) {
        let pgl1 : PGL1Ledger = asPGL1(Principal.toText(game.canister_id));
        let price : Nat = switch (await pgl1.pgl1_price()) {
          case (null) {
            // jika "null" artinya belum di-set / tidak untuk dijual
            return #err(#ValidationError("Game price is not set"));
          };
          case (?p) { p };
        };
        // 2) check app price isFree or Nor
        switch (price <= 0) {
          case (true) {
            let newPurchase : PurchaseType = {
              userId = caller;
              gameId = gameId;
              amount = 0;
              purchasedAt = Time.now();
              txIndex = null;
              memo = null;
            };
            let prev : [PurchaseType] = switch (purchases.get(caller)) {
              case (?arr) arr;
              case (null) [];
            };
            purchases.put(caller, Array.append<PurchaseType>(prev, [newPurchase]));
            return #ok(newPurchase);
          };
          case (false) {
            // 3) idempotent: isUserAlreadyBought?
            let res = await pgl1.pgl1_safeMint(caller, null);
            switch (res) {
              case (#err err) { #err(#NotAuthorized(err)) };
              case (#ok res) {
                // 4) check allowance user → canister
                let userAccount : TokenLedger.Account__1 = {
                  owner = caller;
                  subaccount = null;
                };
                let spender : TokenLedger.Account__1 = {
                  owner = spenderPrincipal;
                  subaccount = null;
                };

                let allow = await tokenLedgerService.icrc2_allowance({
                  account = userAccount;
                  spender;
                });
                if (allow.allowance < price) {
                  return #err(#NotAuthorized("Insufficient allowance; please approve first"));
                };

                // 5) take token: transfer_from(user → merchant)
                let res = await tokenLedgerService.icrc2_transfer_from({
                  from = userAccount;
                  to = merchantAccount(merchantPrincipal);
                  amount = price;
                  fee = null;
                  memo = null;
                  created_at_time = null;
                  spender_subaccount = null;
                });

                switch (res) {
                  case (#Err _e) {
                    return #err(#StorageError("Ledger transfer_from failed"));
                  };
                  case (#Ok txIndex) {
                    // 6) create new purchase
                    let newPurchase : PurchaseType = {
                      userId = caller;
                      gameId = gameId;
                      amount = price;
                      purchasedAt = Time.now();
                      txIndex = ?txIndex;
                      memo = null;
                    };

                    // 7) take old list (can be null) -> append -> put again as array

                    let prev : [PurchaseType] = switch (purchases.get(caller)) {
                      case (?arr) arr;
                      case (null) [];
                    };
                    let updated : [PurchaseType] = Array.append<PurchaseType>(prev, [newPurchase]);
                    purchases.put(caller, updated);
                    return #ok(newPurchase);

                  };
                };
              };
            };
          };
        };

      };
    };
  };

  // get

};
