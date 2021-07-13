package stx.test;

class TestCaseData{
  public final test_case    : TestCase;
  public final clazz        : Classdef;
  public final method_calls : Array<MethodCall>;
  
  public function new(test_case,clazz,method_calls){
    this.test_case       = test_case;
    this.clazz        = clazz;
    this.method_calls = method_calls;
  }
  public function has_failures(){
    var failed = false;
    for(mc in method_calls){
      if(mc.assertions.failures.length > 0){
        failed = true;
        break;
      }
    }
    return failed;
  }
  public function has_assertions(){
    var bool = false;
    for(mc in method_calls){
      bool = mc.has_assertions();
      if(bool){
        break;
      }
    }
    return bool;
  }
  public function toString(){
    return 'TestCaseData(${clazz.path})';
  }
}