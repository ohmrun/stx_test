package stx.test;

class MethodCall{
  public function new(object:TestCase,class_name:String,field_name:String,_call:TestMethodZero,timeout){
    this.object             = object;
    this.class_name         = class_name;
    this.field_name         = field_name;
    this._call              = _call;
    this.timeout            = timeout;
    this.assertions         = [];
  }
  public final object           : TestCase;
  public final class_name       : String;
  public final field_name       : String;
  public final _call            : TestMethodZero;
  public final timeout          : Int;
  public var timestamp          : Float;
  
  //TODO: async assertions?
  public function call():TestResult{
    __.log().blank('call: timeout : ${get_timeout()}');
    __.assert().exists(_call);
    this.timestamp                  = haxe.Timer.stamp();
    /**
      Figuring out which assertions a test has made to avoid PosInfos
    **/
    ///////////////////////////////////////////////////////////////////////////////////////////
    final all_assertions            = @:privateAccess object.__assertions;
    final before_assertions_length  = all_assertions.length;

    var res                         = Util.or_res(_call.prj());
    
    __.log().trace('$res');
    var result = TestResult.lift(res.fold(
      (ok:Option<Async>) -> ok.fold(
        async -> async.asFuture().first(Timeout.make(get_timeout())),
        ()    -> TestResult.unit()
      ),
      no -> TestEffect.fromRefuse(no)
    )).tap(
      (x) -> {
        final after_assertions_length   = all_assertions.length;
        for(i in before_assertions_length ... after_assertions_length){
          this.assertions.push(all_assertions[i]);
        }
      }
    );
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    return result;
  }
  
  @:isVar public var assertions(get,null):Assertions;
  private function get_assertions():Assertions{
    return assertions;
  }
  public function position():Option<Position>{
    final type = std.Type.getClass(object);
    return haxe.rtti.Rtti.hasRtti(type).if_else(
      () -> {
        final clazz = haxe.rtti.Rtti.getRtti(type); 
        final field = clazz.fields.search(
          x -> x.name == this.field_name
        );
        return field.map(
          field -> {
            var parts       = clazz.path.split(".");
            var fileName    = clazz.file;
            var className   = parts[parts.length -1];
            var methodName  = this.field_name;
            var lineNumber  = field.line;
            return Position.make(fileName,className,methodName,lineNumber);        
          }
        );
      },
      () -> None
    );  }
  public function depends(){
    final fields_meta = haxe.rtti.Meta.getFields(std.Type.getClass(object));
    final field_meta  = __.option(fields_meta).flat_map(
      obj -> __.option(Reflect.field(obj,"stx.test.depends"))
    ).flat_map(
      (arr:Array<Dynamic>) -> arr.map(
        (o) -> Std.string(o)
      ).map(
        s -> {
          var out = s.substr(1,s.length-2);
          return out;
        }
      )
    ).defv([]);
    return field_meta;
  }
  public function get_timeout():Int{
    final fields_meta = haxe.rtti.Meta.getFields(std.Type.getClass(this.object));
    final field_meta  = Reflect.field(fields_meta,this.field_name);
    return __.option(Reflect.field(field_meta,"timeout"))
      .map(
        arr -> arr[0]
      ).def(
        () -> this.timeout
      ); 
  }
  public function has_assertions(){
    return this.assertions.is_defined();
  }
  public function toString(){
    var location = this.class_name + this.field_name;
    return 'MethodCall($location)';
  }
  // public function toString(){
  //   var asserts = assertions.map(x -> x.res());
  //   return 'MethodCall($clazz:${field_name}[${asserts}])';
  // }
}