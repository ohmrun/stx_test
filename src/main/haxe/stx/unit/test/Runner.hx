package stx.unit.test;

class Runner{
  public final timeout : Int;
  public function new(?timeout=6000){
    this.timeout = timeout;
  }
  public function apply<T:TestCase>(cases:Array<T>):Signal<Chunk<TestPhaseSum,TestFailure>>{
    return Signal.make(
      (cb) -> {
        var test_cases  : Array<TestCaseData> = cases.map(
          (t:T) -> TestCaseLift.get_tests(t) 
        );
        var data = test_cases.map(Val).snoc(End());

        //trace('apply: Runner');       
        var sig   = Signal.fromArray(data);
        var next  = sig.flat_map(
          (chunk) -> chunk.fold(
            val -> {
              cb(Val(TP_StartTestCase(val)))-;
              return TestCaseDataRun.apply(val);
            },
            end -> __.option(end).fold(
              err -> Signal.pure(Val(TP_ReportFatal(err))),
              ()  -> Signal.pure(End())
            ),
            () -> Signal.pure(Tap)
          )
        );
        next.handle(
          (x) -> x.fold(
            val -> cb(Val(val)),
            end -> __.option(end).fold(
              err -> cb(Val(TP_ReportFatal(err))),
              ()  -> {
                cb(
                  Val(TP_ReportTestSuiteComplete(new TestSuite(test_cases)))
                );
                cb(End());
              }
            ),
            () -> {}
          )
        );
        return () -> {}
      }
    );
  } 
}
class TestCaseDataRun{
  static public function apply(test_case_data:TestCaseData):Signal<Chunk<TestPhaseSum,TestFailure>>{
    return Signal.make(
      (cb) -> {
        //trace('apply: TestCaseDataRun: $test_case_data');
        var sig  = Signal.fromArray(test_case_data.method_calls.map(Val).snoc(End())); 
        var next = sig.flat_map(
          (x:Chunk<MethodCall,TestFailure>) -> x.fold(
            (val) -> {
              cb(Val(TP_StartTest(val)));
              return MethodCallRun.apply(val);
            },
            (end) -> Signal.pure(End(end)),
            ()    -> Signal.pure(Tap)
          )
        );
        next.handle(
          ok -> ok.fold(
            (val) -> cb(Val(val)),
            (end) -> __.option(end).fold(
              err -> cb(Val(TP_ReportFatal(err))),
              ()  -> cb(Val(TP_ReportTestCaseComplete(test_case_data)))
            ),
            () -> {}
          )        
        );
        return () -> {};
      }
    );
  }
}
class MethodCallRun{
  static public function apply(method_call:MethodCall):Signal<Chunk<TestPhaseSum,TestFailure>>{
    return Signal.make(
      (cb) -> {
        //trace('apply: MethodCallRun: $method_call');
        var next  = Signal.fromFuture(method_call.call().map(
          eff -> eff().fold(
            (failure) -> {
              method_call.object.test_error('EFF',failure);
              Noise;
            }
            ,() -> {
              Noise;
            }
          )
        )).flat_map(
          (_:Noise) -> {
            var asserts = method_call.assertions.map(Val).snoc(End());
            return Signal.fromArray(asserts).flat_map(
              (chunk:Chunk<Assertion,TestFailure>) -> chunk.fold(
                val -> AssertionRun.apply(val,method_call),
                end -> __.option(end).fold(
                  (err) -> Signal.pure(Val(TP_ReportFatal(err))),
                  ()    -> Signal.pure(Val(TP_ReportTestComplete(method_call)))
                ),
                () -> Signal.pure(Tap)  
              )
            );
          }
        ).handle(
          (chunk) -> {
            cb(chunk);
          }
        );
        return () -> {}
      }
    );
  }
}
class AssertionRun{
  static public function apply(assertion:Assertion,method_call):Signal<Chunk<TestPhaseSum,TestFailure>>{
    return Signal.make(
      cb -> {
        switch(assertion.truth){
          case false : cb(Val(TP_ReportFailure(assertion,method_call)));
          case true  : 
        }
        return () -> {}
      }
    );
  }
}