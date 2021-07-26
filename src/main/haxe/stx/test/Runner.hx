package stx.test;

class Runner{
  public final timeout : Int;
  public function new(?timeout=6000){
    this.timeout = timeout;
  }
  public function apply<T:TestCase>(cases:Array<T>):Stream<TestPhaseSum,TestFailure>{
    var test_cases  : Array<TestCaseData> = cases.map(
      (t:T) -> TestCaseLift.get_tests(t,timeout) 
    );
    var sig   = Stream.fromArray(test_cases);
    return sig.flat_map(
      val -> {
        __.log().debug('test case $val');
        return Stream.pure(TP_StartTestCase(val))
          .seq(TestCaseDataRun.apply(val,timeout))
          .seq(Stream.effect(() -> {__.log()("After TestCaseDataRun");}));
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
  static public function apply(test_case_data:TestCaseData,timeout):Stream<TestPhaseSum,TestFailure>{
    var setup     = updown(test_case_data.test_case.__setup,timeout,TP_Setup);
    var teardown  = updown(test_case_data.test_case.__teardown,timeout,TP_Teardown);
    return setup.seq(Stream.fromArray(test_case_data.method_calls).flat_map(
      (method_call) -> {
      __.log().debug('apply: TestCaseDataRun: $test_case_data $method_call');
        var init      = Stream.pure(TP_StartTest(method_call));
        var before    = updown(test_case_data.test_case.__before,timeout,TP_Before);
        var after     = updown(test_case_data.test_case.__after,timeout,TP_After);
        return 
          init.seq(before)
              .seq(Stream.effect(() -> __.log().debug("before method_call_run")))
              .seq(MethodCallRun.apply(method_call))
              .seq(Stream.effect(() -> __.log().debug("after method_call_run")))
              .seq(after);
      }
    )).seq(teardown).seq(Stream.pure(TP_ReportTestCaseComplete(test_case_data)));
  }
  static function updown(fn:Void->Option<Async>,timeout:Int,cons){
    __.log().debug('updown');
    return Stream.fromThunkFuture(() -> __.option(fn()).flatten().fold(
      (async) -> async.asFuture().first(Timeout.make(timeout)),
      ()      -> TestResult.unit()
    ).map((x) -> x())
     .map(opt -> opt.fold(cons,()->TP_Null)));

  }
}
class MethodCallRun{
  static public function apply(method_call:MethodCall):Stream<TestPhaseSum,TestFailure>{
    return Stream.fromThunkFuture(() -> method_call.call().map(
      eff -> {
        __.log().debug('${method_call.field.name} called');
        return eff().fold(
          (failure) -> {
            method_call.object.test_error('EFF',failure,method_call.position());
            return Noise;
          },
          () -> Noise
        );
    })).flat_map(
      (_:Noise) -> {
        __.log().debug('having called effects');
        var asserts = method_call.assertions;
        var stream  =  Stream.fromArray(asserts).flat_map(
          (val:Assertion) -> {
            __.log().debug("to run AssertionRun");
            return AssertionRun.apply(val,method_call);
          }
        );
        // stream = Stream.lift(
        //   stream.prj().map(
        //     __.command(
        //       x -> trace(x)
        //     )
        //   )
        // );
        return stream;
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