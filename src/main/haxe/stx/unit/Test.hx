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