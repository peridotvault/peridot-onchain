// Storage.mo
import Core "./Core";
import App "./App";

module {
    public type DownloadRequest = {
        appId : Core.AppId;
        userId : Core.UserId;
        version : Core.Version;
        platform : App.OS;
        installPath : Text;
    };

    public type DownloadJob = {
        jobId : Text;
        request : DownloadRequest;
        status : DownloadStatus;
        progress : Nat;
        startedAt : Core.Timestamp;
        updatedAt : Core.Timestamp;
        completedAt : ?Core.Timestamp;
        error : ?Text;
    };

    public type DownloadStatus = {
        #queued;
        #downloading;
        #verifying;
        #installing;
        #completed;
        #failed;
        #paused;
    };

    public type WasabiConfig = {
        bucket : Text;
        region : Text;
        baseUrl : Text;
        cdnEnabled : Bool;
    };
};
