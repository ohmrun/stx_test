package stx.unit.test;

@:forward(asFuture) abstract Async(FutureTrigger<TestEffect>) from FutureTrigger<TestEffect> to FutureTrigger<TestEffect>{
  static public function wait():Async{
    return Future.trigger();
  }
  public function done(){
    this.trigger(TestEffect.unit());
  }
  // static public function reform(option:Option<Async>,timeout=2000):TestResult{
  //   return option.map(
  //     (x:FutureTrigger<TestEffect>) -> x.asFuture().first(Timeout.make(this,timeout))
  //   ).def();
  // }
}