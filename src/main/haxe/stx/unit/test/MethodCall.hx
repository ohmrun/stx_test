package stx.unit.test;

class MethodCall{
  public function new(object:TestCase,clazz:Classdef,field:ClassField,_call:TestMethodZero){
    this.object       = object;
    this.clazz        = clazz;
    this.field        = field;
    this._call        = _call;
  }
  public final object     : TestCase;
  public final clazz      : Classdef;
  public final field      : ClassField;
  public final _call      : TestMethodZero;

  public var timestamp    : Float;
  
  public function call():TestResult{
    this.timestamp = haxe.Timer.stamp();
    var res = Util.or_res(_call.prj());
    return res.fold(
      (ok:Option<Async>) -> ok.fold(
        async -> async.asFuture().first(Timeout.make(this,2000)),
        ()    -> TestResult.unit()
      ),
      no -> TestEffect.fromErr(no)
    );
  }
  
  public var assertions(get,null):Assertions;
  private function get_assertions():Assertions{
    return @:privateAccess this.object.__assertions.filter(
      (x) -> (x.pos:Position).methodName == this.field.name
    );
  }
  public function position():Position{
    var parts       = this.clazz.path.split(".");
    var fileName    = this.clazz.file;
    var className   = parts[parts.length -1];
    var methodName  = this.field.name;
    var lineNumber  = this.field.line;
    return Position.make(fileName,className,methodName,lineNumber);
  }
  public var name(get,null):String;
  private function get_name():String{
    return field.name;
  }
  public function depends(){
    return field.meta.filter(
      (x : { name : String, params : Array<String> }) -> x.name == 'depends'
    ).flat_map(
      (x : { name : String, params : Array<String> }) -> x.params 
    ).map(
      s -> {
        var out = s.substr(1,s.length-2);
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
  public function has_assertions(){
    //trace(assertions.is_defined());
    return assertions.is_defined();
  }
  public function toString(){
    var location = this.clazz.path + this.field.name;
    return 'MethodCall($location)';
  }
  // public function toString(){
  //   var asserts = assertions.map(x -> x.res());
  //   return 'MethodCall($clazz:${field.name}[${asserts}])';
  // }
}