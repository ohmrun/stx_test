package stx.test;

class TestCaseData{
  public final test_case    : TestCase;
  public final class_name   : String;
  public final method_calls : Cluster<MethodCall>;
  
  public function new(test_case,class_name,method_calls){
    this.test_case          = test_case;
    this.class_name         = class_name;
    this.method_calls       = method_calls;
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
    return 'TestCaseData(${class_name})';
  }
  static public function make(test_case,class_name,method_calls){
    return new TestCaseData(test_case,class_name,method_calls);
  }
  public function copy(?test_case,?class_name,?method_calls){
    return make(
      __.option(test_case).defv(this.test_case),
      __.option(class_name).defv(this.class_name),
      __.option(method_calls).defv(this.method_calls)
    );
  }
}