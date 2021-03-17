package stx.unit;

import haxe.ds.ArraySort;
import equals.Equal as Equality;

class Test{
  
  static public fun
  ction unit<T:TestCase>(wildcard:Wildcard,tests:Array<T>,poke:Array<Dynamic>){
    var results = new Runner().apply(
      if (stx.sys.Env.get("POKE").is_defined()){
        tests.filter(stx.Test.poke(__,poke));
      }else{
        tests;
      }
		).handle(
      (x) -> {
        new Reporter().report(x);
        #if stx.test.shutdown.auto
          #if (sys || hxnodejs)
            __.log('shutting down app...');
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
typedef AnnotatedMethodCall   = stx.unit.test.AnnotatedMethodCall;
typedef Assert                = stx.unit.test.Assert;
typedef Assertion             = stx.unit.test.Assertion;
typedef Assertions            = stx.unit.test.Assertions;
typedef Async                 = stx.unit.test.Async;
typedef AsyncResult           = stx.unit.test.AsyncResult;
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
typedef TestSuite             = stx.unit.test.TestSuite;
typedef Timeout               = stx.unit.test.Timeout;
typedef Util                  = stx.unit.test.Util;
typedef WithPos               = stx.unit.test.WithPos;
typedef WrapedFuture          = stx.unit.test.WrapedFuture;
typedef TestFailure           = stx.fail.TestFailure;
typedef TestMethodZeroDef     = Void->Option<Async>;
typedef TestMethodOneDef      = Async->Void;