package stx.unit;

import haxe.ds.ArraySort;
import equals.Equal as Equality;

class Test{
  static public function unit<T:TestCase>(wildcard:Wildcard,tests:Array<T>,poke:Array<Dynamic>){
    var results = new Runner().apply(
      #if poke
        tests.filter(stx.Test.poke(__,poke))
      #else
        tests
      #end
		).handle(
      (x) -> {
        new Reporter().report(x);
        #if stx.test.shutdown.auto
          #if (sys || hxnodejs)
            Console.log('shutting down app...');
            if(x.is_clean()){
              Sys.exit(0);
            }else{
              Sys.exit(-1);
            }
          #else
            #error
          #end
        #end
      }
    );
  }
}
typedef TestFailure           = stx.fail.TestFailure;
enum TestMethodSum {
  TMZero(m:TestMethodZero);
  TMOne(m:TestMethodOne);
}
abstract TestMethod(TestMethodSum) to TestMethodSum{
  public function  new(self) this = self;
  static public function lift(self){
    return new TestMethod(self);
  }
  static public function fromTestMethodZero(self:TestMethodZero):TestMethod{
    return lift(TMZero(self));
  }
  static public function fromTestMethodOne(self:TestMethodOne):TestMethod{
    return lift(TMOne(self));
  }
  public function prj():TestMethodSum{
    return this;
  }
}
typedef TestMethodZeroDef     = Void->Option<Async>;
typedef TestMethodOneDef      = Async->Void;

@:callable abstract TestMethodZero(TestMethodZeroDef){
  public function new(self) this = self;
  @:noUsing static public function lift(self){
    return new TestMethodZero(self);
  }
  @:noUsing static public function fromVoid(fn:Void->Void):TestMethodZero{
    return lift(() -> {
      fn();
      return None;
    });
  }
  @:noUsing static public function fromAsync(fn:Void->Async):TestMethodZero{
    return lift(() -> {
      return Some(fn());
    });
  }
}

@:callable abstract TestMethodOne(TestMethodOneDef){
  public function new(self) this = self;

  @:noUsing static public function fromCallback(fn:Async->Void):TestMethodOne{
    return new TestMethodOne(fn);
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
  static public function reform(option:Option<Async>):Future<Void->Void>{
    return option.map(
      (x:FutureTrigger<Void->Void>) -> x.asFuture()
    ).defv(
      Future.sync(()->{})
    );
  }
  // public function wrap<T>(ft:Future<T>,?pos:Pos):Future<Res<T,TestFailure>>{
  //   return new Future(
  //     (cb) -> {
  //       return try{
  //         ft.handle(
  //           (v) -> {
  //             cb(__.accept(v));
  //           }
  //         );
  //       }catch(e:Dynamic){
  //         //trace(e);
  //         cb(__.reject(__.fault(pos).of(TestRaisedError(e))));
  //         return null;
  //       }   
  //     }
  //   );
  // }
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
                  'timeout',TestTimedOut(timeout),Position.make(method_call.file,method_call.type,method_call.test,null,null)
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
    var normalized : Array<TestCase> = cases.map(x -> x.asTestCase());
    var a = __.nano().Ft().bind_fold(
      normalized,
      (test_case:TestCase,memo:Array<TestCaseData>) -> {
        var test_case_data = @:privateAccess test_case.__stx__tests();
        var setup          = Async.reform(test_case.__setup());

        var ft = __.nano().Ft().bind_fold(
          test_case_data.data,
          (next:AnnotatedMethodCall,memo:Array<MethodCall>) -> {
            //trace(next);
            var before = Async.reform(test_case.__before());
            return before.flatMap(
              (_) -> {
                return try{
                  var result = next.call();
                  switch(result){
                    case None       : Future.sync(()->{});
                    case Some(ft)   : ft.asFuture();
                  }
                }catch(e:Err<Dynamic>){
                  Future.sync(
                    () -> {
                      next.data.error(e);
                    }
                  );
                }catch(e:Dynamic){
                  Future.sync(  
                    () -> {
                      next.data.error(__.fault().of(TestRaisedError(e)));
                    }
                  );
                }
            }).first(
                Timeout.make(next,next.timeout().defv(timeout))).map(
                (cb) -> {
                  cb();
                  return memo.snoc(next);
                }
            ).flatMap(
              (res) -> {
                var after = Async.reform(test_case.__after());
                return after.map(
                  (_) -> res
                );
              }
            );
          }
          ,[]
        ).map(
          x -> Noise
        );
        return ft.flatMap(
          (x) -> {
            var teardown  = Async.reform(test_case.__teardown());
            return teardown.map(_ -> x);
          }
        ).map((_) -> memo.snoc(test_case_data));
      },
      []
    );
    //$type(a);
    return a.map(
      (tcd) -> return new TestSuite(normalized,tcd)
    );
  } 
}
class TestSuite{
  public final cases : Array<TestCase>;
  public final data  : Array<TestCaseData>;
  public function new(cases,data){
    this.cases = cases;
    this.data  = data;
  } 
  public function is_clean(){
    var clean = true;
    for(tcd in data){
      if(tcd.has_failures()){
        clean = false;
        break;
      }
    }
    return clean;
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
    return this.truth ? __.accept(this.explanation) : __.reject(__.fault(this.pos).of(this.failure));
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
  // public function capture<T>(ft:Future<Res<T,TestFailure>>){
  //   return ft.map(
  //     (res) -> res.fold(
  //       ok ->  Some(ok),
  //       no -> {
  //         raise(no,no.pos);
  //         return None;
  //       }
  //     )
  //   );
  // }
  public function pass(?pos:Pos){
    assert(Assertion.make(true,'assertion passed',NullTestFailure,pos));
  }
  public function fail(reason="force fail",?pos:Pos){
    assert(Assertion.make(false,reason,null,pos));
  }
  public function error(err:Err<Dynamic>){
    assert(Assertion.make(false,err.data.toString(),WhileCalling(err),err.pos));
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
  public function __setup():Option<Async>{
    return None;
  }
  public function __teardown():Option<Async>{
    return None;
  }
  public function __before():Option<Async>{
    return None;
  }
  public function __after():Option<Async>{
    return None;
  }
  public function asTestCase():TestCase{
    return this;
  }
}
class AnnotatedMethodCall extends MethodCall{
  private final field : ClassField;

  public function new(data,file,type,test,call,field){
    super(data,file,type,test,call);
    this.field = field;
  }
  public function depends(){
    return field.meta.filter(
      (x : { name : String, params : Array<String> }) -> x.name == 'depends'
    ).flat_map(
      (x : { name : String, params : Array<String> }) -> x.params 
    ).map(
      s -> {
        //trace(s);
        var out = s.substr(1,s.length-2);
        //trace(out);
        return out;
      }
    );
  }
  public function timeout():Option<Int>{
    return field.meta.search(
      (x) -> x.name == 'timeout'
    ).flat_map(
      (x) -> __.option(x.params).defv([]).head()
    ).map(
      Std.parseInt
    );
  }
}
enum FnType{
  ZeroZero;
  ZeroOne;
  OneZero;
}
class TestCaseLift{
  static public function get_tests<T:TestCase>(v:T){
    var rtti          = Rtti.getRtti(std.Type.getClass(v));
    var fields        = rtti.fields;
    var test_fields   = fields.filter( cf -> cf.name.startsWith('test') );
    var applications  = test_fields.map_filter(
      (cf) -> switch(cf.type){
        case CFunction([],CAbstract('Void',[]))            : 
          Some(get_test(v,rtti,cf,ZeroZero));
        case CFunction([],CAbstract('stx.unit.Async',[]))  : 
          Some(get_test(v,rtti,cf,ZeroOne)
          );
        case CFunction([{ t : CAbstract('stx.unit.Async',[]) } ],CAbstract('Void',[])) :
          Some(get_test(v,rtti,cf,OneZero));
        case CFunction(_,_)  :
          throw 'test* functions have a particular shape: "Void -> Option<Async>" or "Void->Void"\n${cf.name}';
          None;
        default : None;
      }
    );
    var names                = applications.map(
      f -> f.test
    );
    function name_exists(name){
      return names.any(
       (n) -> n == name 
      );
    }
    function depends_on(l:AnnotatedMethodCall,r:AnnotatedMethodCall){
      return __.tracer()(l.depends().any(
        (name) -> {
          trace('${r.test} == $name');
          return r.test == name;
        } 
      ));
    }
    var ordered_applications = applications.copy().map(
      (application) -> {
        var dependencies = application.depends();
        //trace(dependencies.length);
        //trace(dependencies);
        var depends = dependencies.map(
          (s) -> applications.search(
            (application) -> application.test == s
          ).def(
            () -> { throw 'no method named `$s` available on ${application.test}}'; null; } 
          )
        );
        return [application].concat(depends);
      }
    );
    function inner_order(l:Array<AnnotatedMethodCall>,r:Array<AnnotatedMethodCall>){
      return l.tail().any(
        (x:AnnotatedMethodCall) -> {
          return r.any(
            (y:AnnotatedMethodCall) -> {
              return x.test == y.test; 
            }
          );
        }
      );
    }
    //trace(ordered_applications);
    ArraySort.sort(
      ordered_applications,
      function(lhs:Array<AnnotatedMethodCall>,rhs:Array<AnnotatedMethodCall>){
        return if(inner_order(lhs,rhs)){
          -1;
        }else if(inner_order(rhs,lhs)){
          1;
        }else{
          0;
        }
      }
    );
    ordered_applications.reverse();
    var reordered_applications = ordered_applications.map_filter( _ -> _.head());

  return new TestCaseData(rtti,v.asTestCase(),reordered_applications);
  }
  static public function get_pos(def:Classdef,cf:ClassField):Pos{
    return Position.make(def.file,def.path,cf.name,cf.line);
  }
  static public function get_test(test_case:TestCase,def:Classdef,classfield:ClassField,size){
    var name      = classfield.name;
    var type_name = std.Type.getClassName(std.Type.getClass(test_case));
    var call      = make_call(test_case,name,def,classfield,size);
    var file      = def.file;
    return new AnnotatedMethodCall(test_case,file,type_name,name,call,classfield);
  }
  static private function make_call(test_case:TestCase,field_name:String,def:Classdef,cf:ClassField,len:FnType):TestMethodZero{
    var call_zero_zero = ()  -> {
      Reflect.callMethod(test_case,Reflect.field(test_case,field_name),[]);
    }
    var call_zero_one = ()  -> Reflect.callMethod(test_case,Reflect.field(test_case,field_name),[]);
    var call_one  = (v) -> Reflect.callMethod(test_case,Reflect.field(test_case,field_name),[v]);

    function wrap(fn:Void->Option<Async>):Void->Option<Async>{
      return () -> try{
        fn();
      }catch(e:Dynamic){
        test_case.raise(TestRaisedError(e),get_pos(def,cf));
        return None;
      }
    }
    var f0 = () -> { 
      var async = Async.wait();
      call_one(async);
      trace(async);
      return Some(async); 
    }
    //trace(len);
    return TestMethodZero.lift(
      switch(len){
        case ZeroZero : wrap(
          () -> {
            call_zero_zero();
            return None;
          }
        );
        case ZeroOne : wrap(
          () -> {
            var out = __.option(call_zero_one());
            return out;
          }
        );  
        case OneZero : wrap(() -> { 
          //trace("_____");
          var async = Async.wait();
          call_one(async);
          //trace(async);
          return Some(async); 
        }); 
      }
    );
    //return TestMethodZero.lift(f0);
  }
}
class Reporter extends Clazz{ 
  public function report(data:TestSuite){
    function indenter(indent){
      return '$indent\t';
    }
    var green_tick = '<green>✓</green>';
    var gtob       = '<bg_black>$green_tick</bg_black>';

    var red_cross  = '<red>✗</red>';
    var rtob       = '<bg_black>$red_cross</bg_black>';
    var l0       = indenter('');
    var l1       = indenter(l0);

    var tests     = 0;
    var warnings  = 0;
    var errors    = 0;
    var println   = Sys.println;
    for (tcd in data.data){
      //trace(tcd.has_failures());
      //trace(@:privateAccess tcd.val.__assertions);
      //trace(@:privateAccess tcd.val.__assertions.failures);
      final method_call_string_fn = (test:AnnotatedMethodCall) -> '<blue>${test.type}::${test.test}</blue>';
      if(tcd.has_failures()){
        Console.log('$rtob <light_white>${tcd.type.path}</light_white>');
        for(test in tcd.data){
          
          var method_call_string = method_call_string_fn(test);

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
        for(test in tcd.data){
          var method_call_string = method_call_string_fn(test);
          Console.log('$gtob ${l0}${method_call_string} ');
        }
      }
    }
  }
}
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
class MethodCall{
  public function new(data:TestCase,file:String,type:String,test:String,call:TestMethodZero){
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
  public final call  : TestMethodZero;
  
  public var assertions(get,null):Assertions;
  private function get_assertions():Assertions{
    return @:privateAccess this.data.__assertions.filter(
      (x) -> (x.pos:Position).methodName == test
    );
  }
  public function toString(){
    var asserts = assertions.map(x -> x.res());
    return 'MethodCall($type:$test[${asserts}])';
  }
}
class TestTestWorking extends TestCase{
  public function test_2(){
    var async = Async.wait();

    haxe.Timer.delay(
      () -> {
        async.done();
      },
      300
    );
    return async;
  }
  public function test_0(){
    pass();
  }
  public function test_1(){
    equals(1,1);
  }
}
class TestTest extends TestCase{
 
  // public function test_raise(){
  //   throw 'NONR';
  // }
  // public function test_asynchronous_raise(){
  //   var async = Async.wait();

  //   haxe.Timer.delay(
  //     () -> {
  //       //throw "NOOOOO";//NOT handled, should bug out
  //       async.done();
  //     },
  //     300
  //   );
  //   return async;
  // }
  public function test_asynchonous_captured_raise(){
    var ft = new Future(
      (cb) -> {
        // haxe.Timer.delay(
        //   () -> {
        //     throw "JBSDFJB";
        //     cb(true);
        //   },
        //   300
        // );
        throw("JUB");
        cb(true);
        return null;
      }
    );
    var async = Async.wait();
    var ft    = ft;//this.capture(async.wrap(ft));
        ft.handle(
          (x)  -> {
            trace(x);
          }
        );
    return async;
  }
  public function test_assertion(){
    pass();
  }
}
class TestTest2 extends TestCase{
  
}
class DependsTest extends TestCase{
  @depends("test_2")
  public function test_1(){
    pass();
  }
  @depends("test_3")
  public function test_2(){
    pass();
  }
  public function test_3(){
    pass();
  }
  @depends("test_2","test_3")
  public function test_4(){
    pass();
  }
}
class UseAsyncTest extends TestCase{
  public function test_bring(async:Async){
    trace("JERJ");
    pass();
    async.done();
  }
  public function test_timeout(async:Async){
    trace("JERJ");
    pass();
  }
}
class SynchronousErrorTest extends TestCase{
  public function test(){
    throw "caught";
  }
}