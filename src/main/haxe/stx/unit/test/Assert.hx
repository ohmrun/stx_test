package stx.unit.test;

class Assert{
  final __assertions : Assertions;
  public function new(){
    __assertions = [];
  }
  public function assert(assertion){
    __assertions.push(assertion);
  }
  public function equals<T>(self:T,that:T,?explanation:String,?pos:Pos){
    assert(Assertion.make(self == that, explanation,TestFailedBecause(explanation), pos));
  } 
  public function raise(error:Dynamic,?pos:Pos){
    assert(Assertion.make(false,Std.string(error),E_Test_Dynamic(error),pos));
  }
  public function pass(?pos:Pos){
    assert(Assertion.make(true,'assertion passed',NullTestFailure,pos));
  }
  public function fail(reason="force fail",?pos:Pos){
    assert(Assertion.make(false,reason,null,pos));
  }
  public function error(err:Err<Dynamic>,?pos:Pos){
    assert(Assertion.make(false,err.data.toString(),E_Test_Err(err),pos));
  }
  public function same<T>(lhs:T,rhs:T,?explanation='should be the same',?pos:Pos){
    assert(Assertion.make(Equality.equals(lhs,rhs),explanation,null,pos));
  }
  public function isTrue(v:Bool,?explanation='should be true',?pos:Pos){
    assert(Assertion.make(v,explanation,null,pos));
  }
}