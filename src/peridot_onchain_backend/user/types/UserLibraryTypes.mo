import Core "./../../_core_/Core";

module {
  public type Library = {
    appId : Core.AppId;
    userId : Core.UserId;
    currentVersion : Text;
    playtimeMinute : Nat;
    lastPlayed : Core.Timestamp;
    purchasedDate : Core.Timestamp;
  };
};
