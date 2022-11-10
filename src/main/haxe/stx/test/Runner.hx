package stx.test;

class Runner{
  public final timeout : Int;
  public function new(?timeout=6000){
    this.timeout = timeout;
  }
  public function apply<T:TestCase>(cases:Array<T>):Stream<TestPhaseSum,TestFailure>{
    var test_cases  : Array<TestCaseData> = cases.map(
      (t:T) -> @:privateAccess t.__stx__tests(timeout) 
    );
    return applyI(test_cases);
  } 
  public function applyI<T:TestCase>(cases:Cluster<TestCaseData>){
    var sig   = Stream.fromCluster(cases);
    return sig.flat_map(
      val -> {
        __.log().trace('TestCase:= $val');
        return Stream.pure(TP_StartTestCase(val))
          .seq(TestCaseDataRun.apply(val,timeout))
          .seq(Stream.effect(() -> {__.log().debug("After TestCaseDataRun");}));
      }
    ).seq(Stream.pure(TP_ReportTestSuiteComplete(new TestSuite(cases))));
  }
}
class TestCaseDataRun{
  static public function apply(test_case_data:TestCaseData,timeout):Stream<TestPhaseSum,TestFailure>{
    var setup     = updown(test_case_data.test_case.__setup,timeout,TP_Setup);
    var teardown  = updown(test_case_data.test_case.__teardown,timeout,TP_Teardown);
    return setup.seq(Stream.fromCluster(test_case_data.method_calls).flat_map(
      (method_call) -> {
      __.log().trace('apply: TestCaseDataRun: $test_case_data $method_call');
        var init      = Stream.pure(TP_StartTest(method_call));
        var before    = updown(test_case_data.test_case.__before,timeout,TP_Before);
        var after     = updown(test_case_data.test_case.__after,timeout,TP_After);
        return 
          init.seq(before)
              .seq(Stream.effect(() -> __.log().trace('before $test_case_data $method_call')))
              .seq(MethodCallRun.apply(method_call))
              .seq(Stream.effect(() -> __.log().trace('after $test_case_data $method_call')))
              .seq(after);
      }
    )).seq(teardown).seq(Stream.pure(TP_ReportTestCaseComplete(test_case_data)));
  }
  static function updown(fn:Void->Option<Async>,timeout:Int,cons){
    __.log().blank('updown');
    return Stream.fromThunkFuture(() -> __.option(fn()).flatten().fold(
      (async) -> async.asFuture().first(Timeout.make(timeout)),
      ()      -> TestResult.unit()
    ).map((x) -> x())
     .map(
        arr -> arr.is_defined().if_else(
          () -> TP_Failures(arr),
          () -> TP_Null
        )
      )
    );
  }
}
class MethodCallRun{
  static public function apply(method_call:MethodCall):Stream<TestPhaseSum,TestFailure>{
    return Stream.fromThunkFuture(() -> method_call.call().map(
      eff -> {
        __.log().debug('TEST: ${method_call.field_name} called');
        final failures = eff();
        for (failure in failures){
          method_call.assertions.push(Assertion.make(false,'FAIL',failure,method_call.position().defv(null)));
        }
        return Noise;
    })).flat_map(
      (_:Noise) -> {
        __.log().trace('after ${method_call.field_name} effects');
        var asserts = method_call.assertions;
        __.log().trace('assertions: $asserts');
        var stream  =  Stream.fromArray(asserts).flat_map(
          (val:Assertion) -> {
            __.log().trace('before ${method_call.field_name} AssertionRun');
            return AssertionRun.apply(val,method_call);
          }
        );
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