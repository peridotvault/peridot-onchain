import Core "./../../_core_/Core";
import PurchaseTypes "../types/PurchaseTypes";
import Principal "mo:base/Principal";

module PurchaseHandlerModule {
  public class PurchaseHandler() {
    type ApiResponse<T> = Core.ApiResponse<T>;

    public func isUserAlreadyBought(purchases : PurchaseTypes.PurchaseHashMap, gameId : Core.GameId, caller : Principal) : ApiResponse<()> {
      switch (purchases.get(caller)) {
        case (?userPurchases) {
          for (item in userPurchases.vals()) {
            if (item.gameId == gameId) {
              return #err(#AlreadyExists("Game Already Exist"));
            };
          };
          return #ok(());
        };
        case (null) { return #ok(()) };
      };
    };
  };

};
