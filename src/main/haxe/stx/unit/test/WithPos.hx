package stx.unit.test;

@:publicFields typedef WithPos<T> = {
  var pos : Pos;
  var val : T;
}