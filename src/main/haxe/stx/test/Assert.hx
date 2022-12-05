package stx.test;

//TODO raises
class Assert{
  final __assertions : Assertions;
  public function new(){
    __assertions = [];
  }
  public function assert(assertion:Assertion){
    __assertions.push(assertion);
  }
  public function eq<T>(self:T,that:T,eq:Eq<T>,?reason:String,?pos:Pos){
    reason = reasoning(() -> __.explain(self).should().be_equal_to(that),reason);
    assert(Assertion.make(eq.comply(self,that).is_equal(), reason,TestFailedBecause(reason), pos));
  }
  public function equals<T>(self:T,that:T,?reason:String,?pos:Pos){
    reason = reasoning(() -> __.explain(self).should().be_equal_to(that),reason);
    assert(Assertion.make(self == that, reason,TestFailedBecause(reason), pos));
  } 
  public function raise(error:haxe.Exception,?reason:String,?pos:Pos){
    reason = __.option(reason).def( () -> Std.string(error));
    assert(Assertion.make(false,reason,E_Test_Exception(error),pos));
  }
  public function pass(?reason='pass',?pos:Pos){
    assert(Assertion.make(true,reason,NullTestFailure,pos));
  }
  public function fail(reason="force fail",?pos:Pos){
    assert(Assertion.make(false,reason,null,pos));
  }
  public function refuse(err:Refuse<Dynamic>,?pos:Pos){
    assert(Assertion.make(false,err.data.toString(),E_Test_Refuse(err),pos));
  }
  public function error(err:Error<Dynamic>,?pos:Pos){
    assert(Assertion.make(false,err.data.toString(),E_Test_Refuse(err.map(EXTERNAL)),pos));
  }
  public function exception(err:haxe.Exception,?pos:Pos){
    assert(Assertion.make(false,err.details(),E_Test_Exception(err),pos));
  }
  public function error_test(reason:String,err:TestFailure,?pos:Pos){
    assert(Assertion.make(false,reason,err,pos));
  }
  public function same<T>(lhs:T,rhs:T,?reason:String,?pos:Pos){
    reason = reasoning(() -> __.explain(lhs).should().be(rhs,'the same as'),reason);
    assert(Assertion.make(Equality.equals(lhs,rhs),reason,null,pos));
  }
  public function is_true(v:Bool,?reason:String,?pos:Pos){
    reason = reasoning(() -> __.explain(v).should().be(true),reason);
    assert(Assertion.make(v,reason,null,pos));
  }
  public function is_false(v:Bool,?reason:String,?pos:Pos){
    reason = reasoning(() -> __.explain(v).should().be(false),reason);
    assert(Assertion.make(!v,reason,null,pos));
  }
  public function exists(v:Dynamic,?reason:String,?pos:Pos){
    reason = reasoning(() -> __.explain('value').should().exist(),reason);
    assert(Assertion.make(!(v==null),reason,null,pos));
  }
  public function iz(clazz:Class<Dynamic>,v:Dynamic,?reason:String,?pos:Pos){
    reason = reasoning(() -> __.explain(v).should().be(clazz,'a value of type'),reason);
    var truth = switch(std.Type.typeof(v)){
      case TClass(cls)  : cls.identifier() == clazz.identifier();
      default           : false;
    }
    assert(Assertion.make(truth,reason,pos));
  }
  public function raises<T>(fn:Void->Void,reason:String='Expectation of thrown error not met',?pos:Pos){
    var truth = false;
    try{
      fn();
    }catch(e:Dynamic){
      truth = true;
    }
    assert(Assertion.make(truth,reason,pos));
  }
  //TODO tighten this up
  //Top level enum the same.
  public function alike(oI:Dynamic,oII:Dynamic,?reason:String,?pos:Pos){
    var e0 : EnumValue = oI;
    var e1 : EnumValue = oII;
    reason  = reasoning(() -> __.explain(e0).should().be_like(e1),reason);
    var truth = e0.index == e1.index && e0.ctr() == e1.ctr();
    assert(Assertion.make(truth,reason,pos));
  }
  public function accepted(o:Dynamic,?reason:String,?pos:Pos){
    reason = reasoning(() -> __.explain(o).should().be_like(__.accept(null)),reason);
    alike(__.accept(null),o,reason,pos);
  }
  public function reasoning<T>(op:Void->Explained<T>,?def:String){
    return __.option(def).def(
      () -> op().toString()
    );
  }
}