package stx.test;
 
@:forward abstract TestResult(Future<TestEffect>) from Future<TestEffect> to Future<TestEffect>{
  @:noUsing static public function lift(self:Future<TestEffect>){
    return (self:TestResult);
  }
  @:from static inline public function pure(self:TestEffect):TestResult{
    return Future.irreversible(
      (cb) -> {
        cb(self);
      }
    );
  }
  static public function unit():TestResult{
    return pure(TestEffect.unit());
  }
  // public function resolve(test_case:TestCase):Signal<TestPhaseSum>{
  //   return Signal.make(
  //     (cb) -> {
  //       this.handle(
  //         eff -> {
  //           eff().fold(
  //             (err) -> test_case.test_error('ERROR',err),
  //             ()   -> {}
  //           );
  //           cb(TP_Tick("resolve"));
  //         }
  //       );
  //     }
  //   );
  // }
  static public function fromError<E>(err:Error<E>){
    return pure(TestEffect.fromError(err));
  }
  public function concat(that:TestResult){
    return __.nano().Ft().zip(this,that.prj()).map(__.decouple((l:TestEffect,r:TestEffect) -> l.concat(r)));
  }
  public function tap(fn:TestEffect->Void){
    return lift(this.map(
      x -> {
        fn(x);
        return x;
      }
    ));
  }
  public function prj(){
    return this;
  }
} 