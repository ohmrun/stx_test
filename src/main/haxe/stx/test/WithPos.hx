package stx.test;

@:publicFields typedef WithPos<T> = {
  var pos : Pos;
  var val : T;
}