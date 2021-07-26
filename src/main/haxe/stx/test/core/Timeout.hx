package stx.test.core;

class Timeout{
  static public function make(timeout:Int):TestResult{
    return new stx.Timeout(timeout).map(_ -> TestEffect.fromTestFailure(TestTimedOut(timeout)));
  }
}