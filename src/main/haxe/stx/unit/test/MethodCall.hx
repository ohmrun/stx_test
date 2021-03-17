package stx.unit.test;

class MethodCall{
  public function new(data:TestCase,file:String,type:String,test:String,_call:TestMethodZero){
    this.data         = data;
    this.file         = file;
    this.type         = type;
    this.test         = test;
    this.test         = test;
    this._call        = _call;
  }
  public var timestamp  : Float;
  public final data     : TestCase;
  public final file     : String;
  public final type     : String;
  public final test     : String;
  public function call():Option<Async>{
    this.timestamp = haxe.Timer.stamp();
    return _call();
  }
  public final _call     : TestMethodZero;
  
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