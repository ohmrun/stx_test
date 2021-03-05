package stx.unit;

import equals.Equal as Equality;

class Test{
  static public function unit<T:TestCase>(wildcard:Wildcard,tests:Array<T>){
    var results = new Runner().apply(
			tests
		).handle(
      (x) -> new Reporter().report(x)
    );
  }
}
typedef TestFailure       = stx.fail.TestFailure;
typedef TestMethodDef     = Void->Option<Async>;

@:callable abstract TestMethod(TestMethodDef) from TestMethodDef to TestMethodDef{
  @:noUsing static public function fromVoid(fn:Void->Void):TestMethod{
    return () -> {
      fn();
      return None;
    }
  }
  @:noUsing static public function fromAsync(fn:Void->Async):TestMethod{
    return () -> {
      return Some(fn());
    }
  }
}
@:publicFields typedef WithPos<T> = {
  var pos : Pos;
  var val : T;
}
@:forward(asFuture) abstract Async(FutureTrigger<Void->Void>) from FutureTrigger<Void->Void> to FutureTrigger<Void->Void>{
  static public function wait():Async{
    return Future.trigger();
  }
  public function done(){
    this.trigger(() -> {});
  }
  public function wrap<T>(ft:Future<T>,?pos:Pos):Future<Res<T,TestFailure>>{
    return new Future(
      (cb) -> {
        return try{
          ft.handle(
            (v) -> {
              cb(__.accept(v));
            }
          );
        }catch(e:Dynamic){
          //trace(e);
          cb(__.reject(__.fault(pos).of(TestRaisedError(e))));
          return null;
        }   
      }
    );
  }
}
private class Timeout{
  static public function make(method_call:MethodCall,timeout){
    return new Future(
      (cb) -> {
        var cancelled = false;
        haxe.Timer.delay(
          function(){
            //trace("DELAYED");
            if(!cancelled){
              @:privateAccess method_call.data.__assertions.push(
                Assertion.make(false,
                  'timeout',TestTimedOut,Position.make(method_call.file,method_call.type,method_call.test,null,null)
                )
              );
            }
            cb(()->{});
          }
        ,timeout);
        var cbl = function(){
          cancelled = true;
        }
        return cbl;
      }
    );
  }
}
class Runner{
  public final timeout : Int;
  public function new(?timeout=2000){
    this.timeout = timeout;
  }
  public function apply<T:TestCase>(cases:Array<T>){
    var a = __.nano().Ft().bind_fold(
      cases.map(x -> x.asTestCase()),
      (next:TestCase,memo:Array<TestCaseData>) -> {
        var test_case_data = @:privateAccess next.__stx__tests();
 
        var ft = __.nano().Ft().bind_fold(
          test_case_data.data,
          (next:MethodCall,memo:Array<MethodCall>) -> {
            //trace(next);
            var result = next.call();
            //trace(result);
            return (switch(result){
              case None       : Future.sync(memo.cons(next));
              case Some(ft)   : ft.asFuture().map(
                (x) -> {
                  //trace(x);
                  return x;
                }
              ).first(Timeout.make(next,timeout)).map(
                (cb) -> {
                  //trace("wake");
                  cb();
                  //trace("woke");
                  return memo.snoc(next);
                }
              );
            });
          },[]
        ).map(
          x -> Noise
        );
        return ft.map((_) -> memo.snoc(test_case_data));
      },
      []
    );
    //$type(a);
    return a;
  } 
}
typedef AssertionDef = {
  var ?explanation  : String;
  var ?failure      : TestFailure;
  var truth         : Bool;
  var pos           : Pos;
}
@:forward abstract Assertion(AssertionDef) from AssertionDef to AssertionDef {
  static public function make(truth:Bool,explanation:String,?failure:TestFailure,pos:Pos){
    return new Assertion({
      truth         : truth,
      explanation   : explanation,
      failure       : __.option(failure).def(() -> TestFailedBecause(explanation)),
      pos           : pos
    });
  }
  public function res():Res<String,TestFailure>{
    return this.truth ? __.accept(this.explanation) : __.reject(__.fault(this.pos).of(WhileAsserting(this.explanation,this.failure)));
  }
  public function new(self) this = self;
}
@:using(stx.lift.ArrayLift)
@:forward abstract Assertions(Array<Assertion>) from Array<Assertion> to Array<Assertion>{
  public var failures(get,never):Array<Err<TestFailure>>;
  private function get_failures():Array<Err<TestFailure>>{
    return this.map_filter(
      (x) -> x.res().fold(_ -> None,Some)
    );
  }
}
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
    assert(Assertion.make(false,Std.string(error),TestRaisedError(error),pos));
  }
  public function capture<T>(ft:Future<Res<T,TestFailure>>){
    return ft.map(
      (res) -> res.fold(
        ok ->  Some(ok),
        no -> {
          raise(no,no.pos);
          return None;
        }
      )
    );
  }
  public function pass(?pos:Pos){
    assert(Assertion.make(true,'assertion passed',NullTestFailure,pos));
  }
  public function fail(reason="force fail",?pos:Pos){
    assert(Assertion.make(false,reason,null,pos));
  }
  public function same<T>(lhs:T,rhs:T,?explanation='should be the same',?pos:Pos){
    assert(Assertion.make(Equality.equals(lhs,rhs),explanation,null,pos));
  }
  public function isTrue(v:Bool,?explanation='should be true',?pos:Pos){
    assert(Assertion.make(v,explanation,null,pos));
  }
}
@:rtti class TestCase extends Assert{
  private function __stx__tests(){
    return TestCaseLift.get_tests(this);
  }
  public function asTestCase():TestCase{
    return this;
  }
}
class TestCaseLift{
  static public function get_tests<T:TestCase>(v:T){
    var rtti          = Rtti.getRtti(std.Type.getClass(v));
    var fields        = rtti.fields;
    var test_fields   = fields.filter( cf -> cf.name.startsWith('test') );
    var applications  = test_fields.map_filter(
      (cf) -> switch(cf.type){
        case CFunction([],CAbstract('Void',[]))            : 
          Some(get_test(v,rtti,cf,cast TestMethod.fromVoid));
        case CFunction([],CAbstract('stx.unit.Async',[]))  : 
          Some(get_test(v,rtti,cf,cast TestMethod.fromAsync));
        //case CFunction([],CAbstract('stx.unit.Async',[]))  :
        default : None;
      }
    );
    //trace(applications);
    return new TestCaseData(rtti,v.asTestCase(),applications);
  }
  static public function get_pos(def:Classdef,cf:ClassField):Pos{
    return {
      fileName   : def.file,
      className  : def.path,
      methodName : cf.name,
      lineNumber : cf.line
    };
  }
  static public function get_test(test_case:TestCase,def:Classdef,classfield,cons:Function->TestMethod){
    var name      = classfield.name;
    var type_name = std.Type.getClassName(std.Type.getClass(test_case));
    var calling   = caller(test_case,name);
    var test      = cons(calling);
    var call      = surpress(test_case,def,classfield,test);
    var file      = def.file;
    return new MethodCall(test_case,file,type_name,name,call);
  }
  static public function caller(test_case:TestCase,name:String):Function{
    return () -> {
      //trace("called");
      return Reflect.callMethod(test_case,Reflect.field(test_case,name),[]);
    }
  }
  static public function surpress(test_case:TestCase,def:Classdef,cf:ClassField,fn:TestMethod):TestMethod{
    return () -> {
      return try{
        fn();
      }catch(e:Dynamic){
        //trace(e);
        test_case.raise(TestRaisedError(e),get_pos(def,cf));
        None;
      }
    }
  }
}
class Reporter extends Clazz{ 
  public function report(data:Array<TestCaseData>){
    function indenter(indent){
      return '$indent\t';
    }
    var green_tick = '<green>✓</green>';
    var gtob       = '<bg_black>$green_tick</bg_black>';

    var red_cross  = '<red>✗</red>';
    var rtob       = '<bg_black>$red_cross</bg_black>';

    var tests     = 0;
    var warnings  = 0;
    var errors    = 0;
    var println = Sys.println;
    for (tcd in data){
      //trace(tcd.has_failures());
      //trace(@:privateAccess tcd.val.__assertions);
      //trace(@:privateAccess tcd.val.__assertions.failures);
      if(tcd.has_failures()){
        Console.log('$rtob <light_white>${tcd.type.path}</light_white>');
        for(test in tcd.data){
          var l0       = indenter('');
          
          var l1       = indenter(l0);
          final method_call_string = '<blue>${test.type}::${test.test}</blue>';

          var failures = test.assertions.failures;
          //trace(@:privateAccess tcd.val.__assertions);
          //trace(test.assertions);
          if(failures.length > 0){   
            Console.log('${l0}${method_call_string}');
            for(failure in failures){
              Console.log('$rtob <red>${l1}${failure}</red>');
            }
          }else if(test.assertions.length == 0){
            Console.log('${l0}${method_call_string}');
            Console.log('${l1}<yellow>no assertions made</yellow>');
          }else{
            Console.log('$gtob ${l0}${method_call_string} ');
          }
        }
      }else{
        Console.log('$gtob  <light_white>${tcd.type.path}</light_white> ');
      }
    }
  }
}
class TestCaseData{
  public final type : Classdef;
  public final val  : TestCase;
  public final data : Array<MethodCall>;
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
class MethodCall{
  public function new(data:TestCase,file:String,type,test,call){
    this.data       = data;
    this.file       = file;
    this.type       = type;
    this.test       = test;
    this.test       = test;
    this.call       = call;
  }
  public final data  : TestCase;
  public final file  : String;
  public final type  : String;
  public final test  : String;
  public dynamic function call():Option<Async>{
    return None;
  }
  public var assertions(get,null):Assertions;
  private function get_assertions():Assertions{
    return @:privateAccess this.data.__assertions.filter(
      (x) -> x.pos.methodName == test
    );
  }
  public function toString(){
    var asserts = assertions.map(x -> x.res());
    return 'MethodCall($type:$test[${asserts}])';
  }
}
class TestTest extends TestCase{
  public function test_0(){
    var async = Async.wait();

    haxe.Timer.delay(
      () -> {
        async.done();
      },
      300
    );
    return async;
  }
  public function test_1(){
    equals(1,1);
  }
  public function test_raise(){
    throw 'NONR';
  }
  public function test_asynchronous_raise(){
    var async = Async.wait();

    haxe.Timer.delay(
      () -> {
        //throw "NOOOOO";//NOT handled, should bug out
        async.done();
      },
      300
    );
    return async;
  }
  public function test_asynchonous_captured_raise(){
    var ft = new Future(
      (cb) -> {
        haxe.Timer.delay(
          () -> {
            throw "JBSDFJB";
            cb(true);
          },
          300
        );
        return null;
      }
    );
    var async = Async.wait();
    var ft    = this.capture(async.wrap(ft));
    return async;
  }
  public function test_assertion(){
    pass();
  }
}
class TestTest2 extends TestCase{
  
}