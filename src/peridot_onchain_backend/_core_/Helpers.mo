import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";

module Helpers {
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
};
