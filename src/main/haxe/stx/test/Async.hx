package stx.test;

@:forward(asFuture) abstract Async(FutureTrigger<TestEffect>) from FutureTrigger<TestEffect> to FutureTrigger<TestEffect>{
  static public function wait():Async{
    return Future.trigger();
  }
  public function done(){
    this.trigger(TestEffect.unit());
  }
}