package stx.unit.test;

@:callable abstract TestMethodZero(TestMethodZeroDef){
  public function new(self) this = self;
  @:noUsing static public function lift(self){
    return new TestMethodZero(self);
  }
  @:noUsing static public function fromVoid(fn:Void->Void):TestMethodZero{
    return lift(() -> {
      fn();
      return None;
    });
  }
  @:noUsing static public function fromAsync(fn:Void->Async):TestMethodZero{
    return lift(() -> {
      return Some(fn());
    });
  }
}