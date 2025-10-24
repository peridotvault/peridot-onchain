import VoucherType "../types/voucher.type";
import Time "mo:base/Time";

module {
  type Voucher = VoucherType.Voucher;

  public func isVoucherUsable(v : Voucher, caller : Principal) : Bool {
    if (not v.enabled) return false;
    switch (v.expiresAt) {
      case (?t) { if (Time.now() > t) return false };
      case null {};
    };
    if (v.used >= v.maxUses) return false;
    switch (v.bindTo) {
      case (?p) { if (p != caller) return false };
      case null {};
    };
    true;
  };

};
