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
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Order "mo:base/Order";
import PurchaseTypes "../types/PurchaseTypes";

module AppServiceModule {
  type ApiResponse<T> = Core.ApiResponse<T>;
  type AppType = AppTypes.App;
  type PurchaseType = PurchaseTypes.Purchase;

  // CREATE
  public func createApp(apps : AppTypes.AppHashMap, developerId : Core.DeveloperId, input : AppTypes.CreateApp, appId : Core.AppId) : async ApiResponse<AppType> {

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
      title = input.title;
      description = input.description;
      coverImage = null;
      bannerImage = null;
      previews = null;
      price = null;
      requiredAge = null;
      releaseDate = null;
      status = #notPublish;
      createdAt = Time.now();
      category = null;
      appTags = null;
      distributions = null;
      appRatings = null;
    };

    // Store app data
    apps.put(appId, appNewData);
    #ok(appNewData);
  };

  public func updateApp(
    apps : AppTypes.AppHashMap,
    developerId : Core.DeveloperId,
    appId : Core.AppId,
    input : AppTypes.UpdateApp,
  ) : async ApiResponse<AppType> {

    // 1) pastikan caller adalah developer valid
    let isUserDeveloper = await PeridotUser.getDeveloperProfile(developerId);
    switch (isUserDeveloper) {
      case (#err(e)) { return #err(e) };
      case (#ok(_dev)) {};
    };

    // 2) ambil app existing
    let existingOpt = apps.get(appId);
    switch (existingOpt) {
      case null {
        return #err(#NotFound("App with ID " # Nat.toText(appId) # " not found"));
      };
      case (?app) {
        // 3) otorisasi: hanya pemilik app yg boleh update
        if (app.developerId != developerId) {
          return #err(#Unauthorized("Forbidden: you are not the owner of this app"));
        };

        let priceMerged : ?Nat = switch (input.price) {
          case (null) app.price; // pertahankan lama
          case (?p) ?(p * (10 ** Core.Decimal)); // skala ke subunit
        };

        // 4) merge field opsional
        let updatedApp : AppType = {
          appId = appId;
          developerId = app.developerId;
          title = input.title;
          description = input.description;
          coverImage = input.coverImage;
          bannerImage = input.bannerImage;
          previews = input.previews;
          price = priceMerged;
          requiredAge = input.requiredAge;
          releaseDate = input.releaseDate;
          status = input.status;
          createdAt = app.createdAt;
          category = input.category;
          appTags = input.appTags;
          distributions = input.distributions;
          appRatings = app.appRatings;
        };

        // 5) simpan
        apps.put(appId, updatedApp);
        return #ok(updatedApp);
      };
    };
  };

  public func deleteApp(
    apps : AppTypes.AppHashMap,
    developerId : Core.DeveloperId,
    appId : Core.AppId,
  ) : async ApiResponse<Text> {

    // 1) get app existing
    let existingOpt = apps.get(appId);
    switch (existingOpt) {
      case null {
        return #err(#NotFound("App with ID " # Nat.toText(appId) # " not found"));
      };
      case (?app) {
        // 2) otorization: hanya pemilik app yg boleh update
        if (app.developerId != developerId) {
          return #err(#Unauthorized("Forbidden: you are not the developer of this app"));
        };

        // 3) delete
        apps.delete(appId);
        return #ok("Delete App Successfully");
      };
    };
  };

  // GET
  // Developer
  public func getAppByDeveloperId(apps : AppTypes.AppHashMap, developerId : Core.DeveloperId) : ApiResponse<[AppType]> {
    var result : [AppTypes.App] = [];

    // Iterasi semua entry di HashMap
    for ((_, app) in apps.entries()) {
      if (app.developerId == developerId) {
        result := Array.append<AppTypes.App>(result, [app]);
      };
    };

    if (Array.size(result) == 0) {
      return #err(#NotFound("No apps found for developer " # Principal.toText(developerId)));
    };

    return #ok(result);
  };

  public func getAllApps(apps : AppTypes.AppHashMap) : ApiResponse<[AppType]> {
    #ok(Iter.toArray<AppType>(apps.vals()));
  };

  // User
  public func getAllPublishApps(apps : AppTypes.AppHashMap) : ApiResponse<[AppType]> {
    // 1) filter hanya yang status = #publish
    let filtered = Iter.toArray<AppType>(
      Iter.filter<AppType>(
        apps.vals(),
        func(app : AppType) : Bool {
          switch (app.status) {
            case (#publish) { true };
            case _ { false };
          };
        },
      )
    );

    // 2) sort by createdAt desc (terbaru dulu)
    let sorted = Array.sort<AppType>(
      filtered,
      func(a : AppType, b : AppType) : Order.Order {
        if (a.createdAt > b.createdAt) { #less } else if (a.createdAt < b.createdAt) {
          #greater;
        } else { #equal };
      },
    );

    #ok(sorted);
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

  public func getTotalBuyers(appId : Core.AppId, purchases : PurchaseTypes.PurchaseHashMap) : ApiResponse<Nat> {
    var count : Nat = 0;
    for ((userId, list) in purchases.entries()) {
      label search for (p in list.vals()) {
        if (p.appId == appId) { count += 1; break search };
      };
    };
    #ok(count);
  }

};
