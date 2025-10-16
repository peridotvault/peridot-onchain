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

        // 2) check if user already has license
        let hasLicense = await pgl1.verify_license(caller);
        if (hasLicense) {
          return #err(#ValidationError("User already owns this game"));
        };

        let price : Nat = switch (await pgl1.pgl1_price()) {
          case (null) {
            return #err(#ValidationError("Game price is not set"));
          };
          case (?p) { p };
        };

        // 3) handle free games
        if (price <= 0) {
          // Mint license for free game
          let mintRes = await pgl1.pgl1_safeMint(caller, null);
          switch (mintRes) {
            case (#err err) {
              return #err(#StorageError("Failed to mint license: " # err));
            };
            case (#ok _licenseId) {
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
          };
        };

        // 4) handle paid games
        // Check allowance
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

        // 5) Execute payment: transfer_from(user → merchant)
        let transferRes = await tokenLedgerService.icrc2_transfer_from({
          from = userAccount;
          to = merchantAccount(merchantPrincipal);
          amount = price;
          fee = null;
          memo = null;
          created_at_time = null;
          spender_subaccount = null;
        });

        switch (transferRes) {
          case (#Err _e) {
            return #err(#StorageError("Payment failed - ledger transfer_from failed"));
          };
          case (#Ok txIndex) {
            // 6) Payment successful - NOW mint the license
            let mintRes = await pgl1.pgl1_safeMint(caller, null);
            switch (mintRes) {
              case (#err err) {
                // CRITICAL: Payment succeeded but minting failed
                // In production, you should implement refund logic here
                return #err(#StorageError("Payment succeeded but license minting failed: " # err));
              };
              case (#ok _licenseId) {
                // 7) Create purchase record
                let newPurchase : PurchaseType = {
                  userId = caller;
                  gameId = gameId;
                  amount = price;
                  purchasedAt = Time.now();
                  txIndex = ?txIndex;
                  memo = null;
                };

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
