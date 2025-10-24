import Time "mo:base/Time";

module {
  public type Voucher = {
    code : Text; // MVP: plaintext (nanti ganti hash)
    maxUses : Nat;
    used : Nat;
    expiresAt : ?Time.Time;
    bindTo : ?Principal;
    note : ?Text;
    enabled : Bool;
  };
};
