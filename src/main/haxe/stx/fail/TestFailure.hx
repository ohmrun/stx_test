package stx.fail;

enum TestFailureSum{
  NullTestFailure;
  WhileAsserting(?description:String,failure:TestFailure);
  TestFailedBecause(str:String);
  TestTimedOut(after:Int);
  NoTestNamed(name:String);
  
  
  //E_Test_Dynamic(e:Dynamic);
  E_Test_Exception(e:haxe.Exception);
  E_Test_Rejection(err:Rejection<Dynamic>);
}
abstract TestFailure(TestFailureSum) from TestFailureSum to TestFailureSum{
  public function new(self) this = self;
  static public function lift(self:TestFailureSum):TestFailure return new TestFailure(self);

  public function prj():TestFailureSum return this;
  private var self(get,never):TestFailure;
  private function get_self():TestFailure return lift(this);

  public function toString():String{
    return switch(this){
      case E_Test_Exception(e)  : e.toString();
      case E_Test_Rejection(e)  : e.toString();
      default                   : Std.string(this);
    }
  }
  public var stack(get,never)  : Null<haxe.CallStack>;
  public function get_stack(){
    return switch(this){
      case E_Test_Exception(e) : e.stack;
      case E_Test_Rejection(e) : e.stack;
      default                    : null;
    }
  }
}