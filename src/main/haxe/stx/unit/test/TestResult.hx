package stx.unit.test;

@:forward abstract TestResult(Future<TestEffect>) from Future<TestEffect> to Future<TestEffect>{
  @:from static public function pure(self:TestEffect):TestResult{
    return new Future(
      (cb) -> {
        cb(self);
        return () -> {};
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
  static public function fromErr<E>(err:Err<E>){
    return pure(TestEffect.fromErr(err));
  }
} 