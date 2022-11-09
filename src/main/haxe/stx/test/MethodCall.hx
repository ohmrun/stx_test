package stx.test;

class MethodCall{
  public function new(object:TestCase,class_name:String,field_name:String,_call:TestMethodZero,timeout){
    this.object             = object;
    this.class_name         = class_name;
    this.field_name         = field_name;
    this._call              = _call;
    this.timeout            = timeout;
    this.assertions_range   = None;
  }
  public final object           : TestCase;
  public final class_name       : String;
  public final field_name       : String;
  public final _call            : TestMethodZero;
  public final timeout          : Int;
  public var assertions_range   : Option<Couple<Int,Int>>;
  public var timestamp          : Float;
  
  public function call():TestResult{
    __.log().blank('call: timeout : ${get_timeout()}');
    __.assert().exists(_call);
    this.timestamp                  = haxe.Timer.stamp();
    final all_assertions            = @:privateAccess object.__assertions;
    final before_assertions_length  = all_assertions.length;

    var res                         = Util.or_res(_call.prj());
    final after_assertions_length   = all_assertions.length;
    
    var result = res.fold(
      (ok:Option<Async>) -> ok.fold(
        async -> async.asFuture().first(Timeout.make(get_timeout())),
        ()    -> TestResult.unit()
      ),
      no -> TestEffect.fromRefuse(no)
    );
    if(after_assertions_length > before_assertions_length){
      this.assertions_range = Some(__.couple(before_assertions_length,after_assertions_length));
    }
    return result;
  }
  
  public var assertions(get,null):Assertions;
  private function get_assertions():Assertions{
    return assertions_range.fold(
      __.decouple(
        (l,r) -> {
          final all_assertions    = @:privateAccess object.__assertions;
          final these_assertions  = [];
          for( i in l ... r){
            these_assertions.push(all_assertions[i]);
          }
          return these_assertions;
        }
      ),
      () -> []
    );
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
        arr -> Std.parseInt(arr[0])
      ).def(
        () -> this.timeout
      ); 
  }
  public function has_assertions(){
    //trace(assertions.is_defined());
    return this.assertions_range.is_defined();
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