package stx.test;

@:callable abstract TestMethodOne(TestMethodOneDef){
  public function new(self) this = self;

  @:noUsing static public function fromCallback(fn:Async->Void):TestMethodOne{
    return new TestMethodOne(fn);
  }
}