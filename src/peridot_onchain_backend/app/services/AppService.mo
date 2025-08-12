import PeridotUser "canister:peridot_user";

import AppTypes "../types/AppTypes";
import Core "../../core/Core";

import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import PurchaseTypes "../types/PurchaseTypes";

module AppServiceModule {
  type ApiResponse<T> = Core.ApiResponse<T>;
  type AppType = AppTypes.App;
  type PurchaseType = PurchaseTypes.Purchase;

  // CREATE
  public func createApp(apps : AppTypes.AppHashMap, developerId : Core.UserId, createApp : AppTypes.CreateApp, appId : Core.AppId) : async ApiResponse<AppType> {

    let isUserDeveloper = await PeridotUser.getDeveloperProfile(developerId);

    switch (isUserDeveloper) {
      case (#err(error)) {
        return #err(error);
      };
      case (#ok(_dev)) {};
    };

    let appNewData : AppType = {
      appId = appId;
      developerId = developerId;
      title = createApp.title;
      description = createApp.description;
      coverImage = createApp.coverImage;
      previews = createApp.previews;
      price = createApp.price;
      requiredAge = createApp.requiredAge;
      releaseDate = createApp.releaseDate;
      status = createApp.status;
      createdAt = Time.now();
      category = createApp.category;
      appTags = createApp.appTags;
      distributions = createApp.distributions;
      appRatings = null;
    };

    // Store app data
    apps.put(appId, appNewData);
    #ok(appNewData);
  };

  // GET
  // Developer

  // User
  public func getAllApps(apps : AppTypes.AppHashMap) : ApiResponse<[AppType]> {
    #ok(Iter.toArray<AppType>(apps.vals()));
  };

  public func getAppById(apps : AppTypes.AppHashMap, appId : Core.AppId) : ApiResponse<AppType> {
    switch (apps.get(appId)) {
      case (null) {
        #err(#NotFound("App with ID " # Nat.toText(appId) # " not found"));
      };
      case (?app) { #ok(app) };
    };
  };

  public func getMyApps(apps : AppTypes.AppHashMap, purchases : PurchaseTypes.PurchaseHashMap, userId : Core.UserId) : async ApiResponse<[AppType]> {
    let myPurchases : [PurchaseType] = switch (purchases.get(userId)) {
      case (null) { [] };
      case (?arr) { arr };
    };

    if (myPurchases.size() == 0) { return #ok([]) };

    // set sederhana untuk cegah duplikat appId
    let seen = HashMap.HashMap<Core.AppId, ()>(
      0,
      Nat.equal,
      func(id : Core.AppId) : Hash.Hash {
        Text.hash(Nat.toText(id));
      },
    );
    let out = Buffer.Buffer<AppType>(myPurchases.size());

    for (p in myPurchases.vals()) {
      if (seen.get(p.appId) == null) {
        seen.put(p.appId, ());
        switch (apps.get(p.appId)) {
          case (?app) { out.add(app) };
          case (null) {};
        };
      };
    };

    #ok(Buffer.toArray(out));
  };

};
