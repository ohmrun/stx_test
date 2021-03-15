package stx.fail;

enum TestFailure{
  NullTestFailure;
  WhileAsserting(?description:String,failure:TestFailure);
  TestFailedBecause(str:String);
  TestRaisedError(e:Dynamic);
  TestTimedOut(after:Int);
  NoTestNamed(name:String);
  WhileCalling(err:stx.nano.Err<Dynamic>);
}