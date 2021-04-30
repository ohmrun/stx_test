package stx.unit;


class Test{
  
  static public function unit<T:TestCase>(wildcard:Wildcard,tests:Array<T>,poke:Array<Dynamic>){
    new Reporter(new Runner().apply(
      if (stx.sys.Env.get("POKE").is_defined()){
        tests.filter(stx.Test.poke(__,poke));
      }else{
        tests;
      }
		)).enact();
  }
  static public function explain<T>(wildcard:Wildcard,val:T,?ctr:T->String):Explain<T>{
    return new Explain(val,ctr);
  }
}
typedef Assert                = stx.unit.test.Assert;
typedef Assertion             = stx.unit.test.Assertion;
typedef Assertions            = stx.unit.test.Assertions;
typedef Async                 = stx.unit.test.Async;
typedef AsyncResult<T>        = stx.unit.test.AsyncResult<T>;
typedef Dependencies          = stx.unit.test.Dependencies;
typedef FnType                = stx.unit.test.FnType;
typedef MethodCall            = stx.unit.test.MethodCall;
typedef Reporter              = stx.unit.test.Reporter;
typedef Runner                = stx.unit.test.Runner;
typedef TestCase              = stx.unit.test.TestCase;
typedef TestCaseData          = stx.unit.test.TestCaseData;
typedef TestCaseLift          = stx.unit.test.TestCaseLift;
typedef TestMethod            = stx.unit.test.TestMethod;
typedef TestMethodOne         = stx.unit.test.TestMethodOne;
typedef TestMethodZero        = stx.unit.test.TestMethodZero;
typedef TestPhaseSum          = stx.unit.test.TestPhaseSum;
typedef TestResult            = stx.unit.test.TestResult;
typedef TestSuite             = stx.unit.test.TestSuite;
typedef Timeout               = stx.unit.test.Timeout;
typedef Util                  = stx.unit.test.Util;
typedef WithPos<T>            = stx.unit.test.WithPos<T>;
typedef WrappedFuture<T>      = stx.unit.test.WrappedFuture<T>;
typedef TestFailure           = stx.fail.TestFailure;
typedef TestMethodZeroDef     = Void->Option<Async>;
typedef TestMethodOneDef      = Async->Void;

class Explain<T>{
  var val : T;
  var ctr : T -> String;
  public function new(val:T,?ctr:T->String){
    this.val = val;
    this.ctr = __.option(ctr).defv(Std.string);
  }  
  public function should(){
    return new Explainers(this);
  }
  public function match(sentence:String,?args:Array<Dynamic>){
    var arr : Array<Dynamic> = [ctr(val)];
    return new Explained(sentence,arr.concat(__.option(args).defv([])));
  }
}
class Explainers<T>{
  var explain : Explain<T>;
  public function new(explain){
    this.explain = explain;
  }
  private function go(rest:String,?args:Array<Dynamic>){
    return explain.match('%s should $rest',args);
  }
  public function be_like(v:T){
    return go('be like %s.',[v]);
  }
  public function be(v:T,?words:String=""){
    var s = words == "" ? 'be %s' : 'be $words %s';
    return go('$s',[v]);
  }
  public function be_equal_to(v:T){
    return go('be equal to %s',[v]);
  }
  public function contain(v:T){
    return go('contain %s',[v]);
  }
  public function exist(){
    return go('should exist.');
  }
  public function raises(d:Dynamic){
    return go('raise error: %s',[d]);
  }
}
class Explained<T> {
  var sentence   : String;
  var values     : Array<Dynamic>;

  public function new(sentence,values){
    this.sentence = sentence;
    this.values   = values;
  }
  public function toString(){
    return Printf.format(sentence,values.map(x -> '$x'));
  }
}