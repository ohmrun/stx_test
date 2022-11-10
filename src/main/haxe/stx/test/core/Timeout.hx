package stx.test.core;

class Timeout{
  @:noUsing static public function make(timeout:Int):TestResult{
    //trace('make timeout');
    return new stx.Timeout(timeout).map(
      _ -> {
        //trace('timeout called');
        return TestEffect.fromTestFailure(TestTimedOut(timeout));
      }
    );
  }
}