import UserTypes "../types/UserTypes";
import DeveloperTypes "../types/DeveloperTypes";

import Core "../../_core_/Core";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Bool "mo:base/Bool";
import TokenLedger "./../../_core_/shared/TokenLedger";
// import Int "mo:base/Int";
// import Array "mo:base/Array";
// import Buffer "mo:base/Buffer";
// import AppAnnouncement "../../app/types/AppAnnouncement";

module {
  type ApiResponse<T> = Core.ApiResponse<T>;
  type UserType = UserTypes.User;
  type DeveloperType = DeveloperTypes.Developer;

  public func merchantAccount(self : Principal) : TokenLedger.Account__1 {
    { owner = self; subaccount = null };
  };

  // create
  public func createDeveloperProfile(users : UserTypes.UsersHashMap, userId : Core.UserId, website : Text, bio : Text, tokenLedgerCanister : Text, spenderPrincipal : Principal, priceUpgradeToDeveloperAccount : Nat, merchant : Principal) : async ApiResponse<UserType> {
    let tokenLedgerService : TokenLedger.Self = actor (tokenLedgerCanister);

    // 1. check if user already register
    switch (users.get(userId)) {
      case (null) {
        return #err(#NotFound("User not found"));
      };
      case (?existing) {
        // 2. check allowance user → canister
        let userAccount : TokenLedger.Account__1 = {
          owner = userId;
          subaccount = null;
        };
        let spender : TokenLedger.Account__1 = {
          owner = spenderPrincipal;
          subaccount = null;
        };

        let allow = await tokenLedgerService.icrc2_allowance({
          account = userAccount;
          spender = spender;
        });

        if (allow.allowance < priceUpgradeToDeveloperAccount) {
          return #err(#NotAuthorized("Insufficient allowance; please approve first"));
        };

        // 3) take token: transfer_from(user → merchant)
        let res = await tokenLedgerService.icrc2_transfer_from({
          from = userAccount;
          to = merchantAccount(merchant);
          amount = priceUpgradeToDeveloperAccount;
          fee = null;
          memo = null;
          created_at_time = null;
          spender_subaccount = null;
        });

        // 4) check is error
        switch (res) {
          case (#Err e) {
            return #err(#StorageError("Ledger transfer_from failed " # debug_show (e)));
          };
          case (#Ok _idx) {
            // 5) update data
            let newDeveloper : DeveloperType = {
              developerWebsite = website;
              developerBio = bio;
              totalFollower = 0;
              joinedDate = Time.now();
              announcements = null;
            };

            let updatedUser : UserType = {
              existing with
              developer = ?newDeveloper;
            };

            users.put(userId, updatedUser);
            #ok(updatedUser);
          };
        };
      };
    };
  };

  public func updateFollowDeveloper(users : UserTypes.UsersHashMap, follows : DeveloperTypes.FollowsHashMap, userId : Core.UserId, developerId : Principal) : ApiResponse<DeveloperTypes.DeveloperFollow> {
    if (Principal.equal(userId, developerId)) {
      return #err(#InvalidInput("Cannot follow yourself"));
    };

    let followId = getFollowId(developerId, userId);

    switch (follows.get(followId)) {
      case (?_) {
        return #err(#AlreadyExists("Already following this developer"));
      };
      case (null) {
        switch (users.get(developerId)) {
          case (null) {
            return #err(#NotFound("Developer not found"));
          };
          case (?user) {
            switch (user.developer) {
              case (null) {
                return #err(#NotFound("Developer profile not found"));
              };
              case (?dev) {
                let newFollow : DeveloperTypes.DeveloperFollow = {
                  developerId = developerId;
                  followerId = userId;
                  createdAt = Time.now();
                };

                follows.put(followId, newFollow);

                // Update developer's follower count
                let updatedDev : DeveloperType = {
                  dev with
                  totalFollower = dev.totalFollower + 1;
                };

                let updatedUser : UserType = {
                  user with
                  developer = ?updatedDev;
                };

                users.put(developerId, updatedUser);
                #ok(newFollow);
              };
            };
          };
        };
      };
    };
  };

  //   update
  public func updateUnfollowDeveloper(users : UserTypes.UsersHashMap, follows : DeveloperTypes.FollowsHashMap, userId : Core.UserId, developerId : Principal) : ApiResponse<()> {
    let followId = getFollowId(developerId, userId);

    switch (follows.get(followId)) {
      case (null) {
        return #err(#NotFound("Not following this developer"));
      };
      case (?_) {
        switch (users.get(developerId)) {
          case (null) {
            return #err(#NotFound("Developer not found"));
          };
          case (?user) {
            switch (user.developer) {
              case (null) {
                return #err(#NotFound("Developer profile not found"));
              };
              case (?dev) {
                follows.delete(followId);

                // Update developer's follower count
                let updatedDev : DeveloperTypes.Developer = {
                  dev with
                  totalFollower = if (dev.totalFollower > 0) dev.totalFollower - 1 else 0;
                };

                let updatedUser : UserType = {
                  user with
                  developer = ?updatedDev;
                };

                users.put(developerId, updatedUser);
                #ok(());
              };
            };
          };
        };
      };
    };
  };

  // get
  public func getAmIDeveloper(users : UserTypes.UsersHashMap, principal_id : Principal) : Bool {
    switch (users.get(principal_id)) {
      case (null) {
        return false;
      };
      case (?user) {
        switch (user.developer) {
          case (null) {
            return false;
          };
          case (_) {
            return true;
          };
        };
      };
    };
  };

  public func getDeveloperProfile(users : UserTypes.UsersHashMap, principal_id : Principal) : ApiResponse<DeveloperType> {
    switch (users.get(principal_id)) {
      case (null) {
        return #err(#NotFound("User not found"));
      };
      case (?user) {
        switch (user.developer) {
          case (null) {
            return #err(#NotFound("Developer profile not found"));
          };
          case (?dev) {
            #ok(dev);
          };
        };
      };
    };
  };

  private func getFollowId(developer : Principal, follower : Principal) : Text {
    return Principal.toText(developer) # "_" # Principal.toText(follower);
  };

};
