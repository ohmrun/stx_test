package stx;

using stx.Pico;
using stx.Nano;
using stx.Fail;
using stx.Log;
using stx.Assert;

class Test{
  static public function poke(wildcard:Wildcard,arr:Array<Dynamic>){ 
    __.log().debug((x) -> x.thunk(arr.map.bind(__.definition)));
    return arr.map(__.that().iz)
      .lfold1(__.that().or)
      .defv(__.that().never())
      .check();
  }
  static public function test<T:TestCase>(wildcard:Wildcard){
    return new stx.test.Module();
  }
  static public function explain<T>(wildcard:Wildcard,val:T,?ctr:T->String):Explain<T>{
    return new Explain(val,ctr);
  }
}
typedef Assert                = stx.test.Assert;

typedef Assertions            = stx.test.Assertions;
typedef Async                 = stx.test.Async;
typedef AsyncResult<T>        = stx.test.AsyncResult<T>;
typedef FnType                = stx.test.FnType;
typedef MethodCall            = stx.test.MethodCall;
typedef Reporter              = stx.test.Reporter;
typedef Runner                = stx.test.Runner;
typedef TestCase              = stx.test.TestCase;
typedef TestCaseData          = stx.test.TestCaseData;
typedef TestCaseLift          = stx.test.TestCaseLift;
typedef TestMethod            = stx.test.TestMethod;
typedef TestMethodOne         = stx.test.TestMethodOne;
typedef TestMethodZero        = stx.test.TestMethodZero;
typedef TestPhaseSum          = stx.test.TestPhaseSum;
typedef TestResult            = stx.test.TestResult;
typedef TestSuite             = stx.test.TestSuite;
typedef Util                  = stx.test.Util;
typedef WithPos<T>            = stx.test.WithPos<T>;
typedef WrappedFuture<T>      = stx.test.WrappedFuture<T>;
typedef TestFailure           = stx.fail.TestFailure;
typedef TestFailureSum        = stx.fail.TestFailure.TestFailureSum;
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
  public function raises(e:haxe.Exception){
    return go('raise error: %s',[e]);
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