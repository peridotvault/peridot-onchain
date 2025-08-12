import Core "./../../core/Core";

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
