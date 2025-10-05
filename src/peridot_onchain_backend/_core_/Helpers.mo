import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Core "Core";

module Helpers {
  type ApiResponse<T> = Core.ApiResponse<T>;

  public func sliceIter<T>(it : Iter.Iter<T>, start : Nat, limit : Nat) : [T] {
    var i : Nat = 0;
    var taken : Nat = 0;
    let buf = Buffer.Buffer<T>(limit);
    label L for (v in it) {
      if (i < start) { i += 1; continue L };
      if (taken >= limit) { break L };
      buf.add(v);
      i += 1;
      taken += 1;
    };
    Buffer.toArray(buf);
  };

  public func expectOk<T>(resp : ApiResponse<T>, ctx : Text) : T {
    switch (resp) {
      case (#ok v) v;
      case (#err _) Debug.trap("Registry error at " # ctx);
    };
  };
};
