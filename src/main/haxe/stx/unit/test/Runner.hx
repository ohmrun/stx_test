package stx.unit.test;

class Runner{
  public final timeout : Int;
  public function new(?timeout=6000){
    this.timeout = timeout;
  }
  public function apply<T:TestCase>(cases:Array<T>):Stream<TestPhaseSum,TestFailure>{
    var test_cases  : Array<TestCaseData> = cases.map(
      (t:T) -> TestCaseLift.get_tests(t) 
    );
    var sig   = Stream.fromArray(test_cases);
    return sig.flat_map(
      val -> {
        //__.log().debug('test case $val');
        return Stream.pure(TP_StartTestCase(val)).seq(TestCaseDataRun.apply(val));
      }
    ).seq(Stream.pure(TP_ReportTestSuiteComplete(new TestSuite(test_cases))));
    // return Stream.make(
    //   (cb) -> {
    //     
    //     __.log().debug('apply: Runner');       
        
    //     // next.handle(
    //     //   (x) -> x.fold(
    //     //     val -> cb(Val(val)),
    //     //     end -> __.option(end).fold(
    //     //       err -> cb(Val(TP_ReportFatal(err))),
    //     //       ()  -> {
    //     //         cb(
    //     //           Val(TP_ReportTestSuiteComplete(new TestSuite(test_cases)))
    //     //         );
    //     //         //cb(End());
    //     //       }
    //     //     ),
    //     //     () -> {}
    //     //   )
    //     // );
    //     return () -> {}
    //   }
    // );
  } 
}
class TestCaseDataRun{
  static public function apply(test_case_data:TestCaseData):Stream<TestPhaseSum,TestFailure>{
    return Stream.fromArray(test_case_data.method_calls).flat_map(
      (val) -> {
        //__.log().debug('apply: TestCaseDataRun: $test_case_data');
        return Stream.pure(TP_StartTest(val)).seq(MethodCallRun.apply(val));
      }
    ).seq(Stream.pure(TP_ReportTestCaseComplete(test_case_data)));
  }
}
class MethodCallRun{
  static public function apply(method_call:MethodCall):Stream<TestPhaseSum,TestFailure>{
    return Stream.fromThunkFuture(() -> method_call.call().map(
      eff -> {
        //__.log().debug('${method_call.field.name} called');
        return eff().fold(
          (failure) -> {
            method_call.object.test_error('EFF',failure);
            return Noise;
          },
          () -> Noise
        );
    })).flat_map(
      (_:Noise) -> {
        //trace('having called effects');
        var asserts = method_call.assertions;
        return Stream.fromArray(asserts).flat_map(
          (val:Assertion) -> AssertionRun.apply(val,method_call)
        );
      }
    );
  }
}
class AssertionRun{
  static public function apply(assertion:Assertion,method_call):Stream<TestPhaseSum,TestFailure>{
    return assertion.truth.if_else(
      () -> Stream.unit(),
      () -> Stream.pure(TP_ReportFailure(assertion,method_call))
    );
  }
}