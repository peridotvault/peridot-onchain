import Core "../../core/Core";
import AppTypes "../types/AppTypes";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Array "mo:base/Array";
import PurchaseTypes "../types/PurchaseTypes";
import PurchaseHandler "../handlers/PurchaseHandler";
import TokenLedger "./../../shared/TokenLedger";

module PurchaseServiceModule {
  type ApiResponse<T> = Core.ApiResponse<T>;
  type PurchaseType = PurchaseTypes.Purchase;
  type AppType = AppTypes.App;

  // peridot account (peridot address)
  public func merchantAccount(self : Principal) : TokenLedger.Account {
    { owner = self; subaccount = null };
  };

  //   create
  public func buyApp(purchases : PurchaseTypes.PurchaseHashMap, apps : AppTypes.AppHashMap, appId : Core.AppId, userId : Core.UserId, tokenLedger : Text, spenderPrincipal : Core.UserId) : async ApiResponse<PurchaseType> {
    let tokenLedgerService : TokenLedger.Self = actor (tokenLedger);
    // 1) get app
    switch (apps.get(appId)) {
      case (null) {
        return #err(#NotFound("The App not found"));
      };
      case (?app) {
        // 2) check app price isFree or Nor
        switch (app.price <= 0) {
          case (true) {
            let newPurchase : PurchaseType = {
              userId = userId;
              appId = appId;
              amount = 0;
              purchasedAt = Time.now();
              txIndex = null;
              memo = null;
            };
            let prev : [PurchaseType] = switch (purchases.get(userId)) {
              case (?arr) arr;
              case (null) [];
            };
            purchases.put(userId, Array.append<PurchaseType>(prev, [newPurchase]));
            return #ok(newPurchase);
          };
          case (false) {
            // 3) idempotent: isUserAlreadyBought?
            switch (PurchaseHandler.PurchaseHandler().isUserAlreadyBought(purchases, appId, userId)) {
              case (#err(error)) { return #err(error) };
              case (#ok()) {
                // 4) check allowance user → canister
                let userAccount : TokenLedger.Account = {
                  owner = userId;
                  subaccount = null;
                };
                let spender : TokenLedger.Account = {
                  owner = spenderPrincipal;
                  subaccount = null;
                };

                let allow = await tokenLedgerService.icrc2_allowance({
                  account = userAccount;
                  spender;
                });
                if (allow.allowance < app.price) {
                  return #err(#NotAuthorized("Insufficient allowance; please approve first"));
                };

                // 5) take token: transfer_from(user → merchant)
                let res = await tokenLedgerService.icrc2_transfer_from({
                  from = userAccount;
                  to = merchantAccount(spenderPrincipal);
                  amount = app.price;
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
                      userId = userId;
                      appId = appId;
                      amount = app.price;
                      purchasedAt = Time.now();
                      txIndex = ?txIndex;
                      memo = null;
                    };

                    // 7) take old list (can be null) -> append -> put again as array
                    let prev : [PurchaseType] = switch (purchases.get(userId)) {
                      case (?arr) arr;
                      case (null) [];
                    };
                    let updated : [PurchaseType] = Array.append<PurchaseType>(prev, [newPurchase]);
                    purchases.put(userId, updated);
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
