package stx.unit.test;

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
}