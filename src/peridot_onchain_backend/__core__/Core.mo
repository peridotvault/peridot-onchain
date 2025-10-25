import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

module {
  // public let TokenLedgerCanister : Text = "b4osj-vyaaa-aaaap-an4bq-cai";
  public let Decimal : Nat = 1_0000_0000;
  public let PeridotAccount : Text = "qmc7g-dzjeq-haics-mfv4z-a6ypg-3m3yo-cvdrf-kyy3a-aiguy-5yvzh-kae";
  public type Timestamp = Time.Time;
  public type AppId = Nat;
  public type AnnouncementId = Nat;
  public type UserId = Principal;
  public type DeveloperId = Principal;
  public type TokenLedgerId = Principal;
  public type Version = Text;
  public type Country = Text;
  public type Language = Text;
  public type Category = Text;
  public type TagGroup = Text;
  public type Tag = Text;

  // new type
  public type GameId = Text; // contoh: "com.peridotvault.vaultbreakers"
  public type Developer = Principal;

  // Status =========================
  public type AppStatus = {
    #publish;
    #notPublish;
  };

  public type Status = {
    #accept;
    #pending;
    #decline;
  };

  // For uniform error handling
  public type ApiResponse<T> = Result.Result<T, ApiError>;
  public type ApiError = {
    #NotFound : Text;
    #AlreadyExists : Text;
    #InvalidInput : Text;
    #StorageError : Text;
    #Unauthorized : Text;
    #InternalError : Text;
    #ValidationError : Text;
    #NotAuthorized : Text;
  };
};
