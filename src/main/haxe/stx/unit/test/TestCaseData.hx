package stx.unit.test;

class TestCaseData{
  public final type : Classdef;
  public final val  : TestCase;
  public final data : Array<AnnotatedMethodCall>;
  
  public function new(type,val,data){
    this.type = type;
    this.val  = val;
    this.data = data;
  }
  public function has_failures(){
    var failed = false;
    for(mc in data){
      if(mc.assertions.failures.length > 0){
        failed = true;
        break;
      }
    }
    return failed;
  }
}