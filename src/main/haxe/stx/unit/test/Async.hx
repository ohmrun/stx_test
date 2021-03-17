package stx.unit.test;

@:forward(asFuture) abstract Async(FutureTrigger<Void->Void>) from FutureTrigger<Void->Void> to FutureTrigger<Void->Void>{
  static public function wait():Async{
    return Future.trigger();
  }
  public function done(){
    this.trigger(() -> {});
  }
  static public function reform(option:Option<Async>):Future<Void->Void>{
    return option.map(
      (x:FutureTrigger<Void->Void>) -> x.asFuture()
    ).defv(
      Future.irreversible((cb) -> cb(()->{}))
    );
  }
}