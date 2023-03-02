package;

@stx.dotted("ok")
class TestMetaGets{
  static public function main(){
    final self = new TestMetaGets();
  } 
  public function new(){
    var metas = haxe.rtti.Meta.getType(std.Type.getClass(this));
    var data  = Reflect.field(metas,'stx.dotted');
    trace(data);
  }
}