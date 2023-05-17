package stx.test.core;

class Timeout{
  @:noUsing static public function make(timeout:Int):TestResult{
    __.assert().that().exists(timeout);
    __.log().trace('make timeout');
    return new stx.Timeout(timeout).map(
      _ -> {
        __.log().trace('timeout called');
        return TestEffect.fromTestFailure(TestTimedOut(timeout));
      }
    );
  }
}