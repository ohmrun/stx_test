package stx.fail;

enum TestFailure{
  NullTestFailure;
  WhileAsserting(?description:String,failure:TestFailure);
  TestFailedBecause(str:String);
  TestTimedOut(after:Int);
  NoTestNamed(name:String);
  
  
  E_Test_Dynamic(e:Dynamic);
  E_Test_Err(err:stx.pico.Error<Dynamic>);
}