import Core "./../../_core_/Core";
import PurchaseTypes "../types/PurchaseTypes";

module PurchaseHandlerModule {
  public class PurchaseHandler() {
    type ApiResponse<T> = Core.ApiResponse<T>;

    public func isUserAlreadyBought(purchases : PurchaseTypes.PurchaseHashMap, appId : Core.AppId, userId : Core.UserId) : ApiResponse<()> {
      switch (purchases.get(userId)) {
        case (?userPurchases) {
          for (item in userPurchases.vals()) {
            if (item.appId == appId) {
              return #err(#AlreadyExists("App Already Exist"));
            };
          };
          return #ok(());
        };
        case (null) { return #ok(()) };
      };

    }

  };

};
