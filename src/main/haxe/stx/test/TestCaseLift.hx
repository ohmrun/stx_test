package stx.test;

class TestCaseLift{
  static public function get_tests<T:TestCase>(v:T,timeout:Int){
    var clazz         = std.Type.getClass(v);
    //trace(clazz);
    var rtti          = Rtti.getRtti(clazz);
    var fields        = rtti.fields;
    var test_fields   = fields.filter( cf -> cf.name.startsWith('test') );
    var applications  = test_fields.map_filter(
      (cf) -> {
        __.log().trace('${cf.name}: ${cf.type}');
        return switch(cf.type){
          case CFunction([],CAbstract('Void',[]))            : 
            //__.log().debug('${cf.name} ZeroZero');
            Some(get_test(v,rtti,cf,ZeroZero,timeout));
          case CFunction([],CAbstract('stx.test.Async',[]))  :
            //__.log().debug('${cf.name} ZeroOne'); 
            Some(get_test(v,rtti,cf,ZeroOne,timeout));
          case CFunction([],CTypedef('stx.Async',[]))  : 
            //__.log().debug('${cf.name} ZeroOne');
            Some(get_test(v,rtti,cf,ZeroOne,timeout));
          case CFunction([{ t : CTypedef('stx.Async',[]) } ],CAbstract('Void',[])) :
            //__.log().debug('${cf.name} OneZero');
            Some(get_test(v,rtti,cf,OneZero,timeout));
          case CFunction([{ t : CAbstract('stx.test.Async',[]) } ],CAbstract('Void',[])) :
            //__.log().debug('${cf.name} OneZero');
            Some(get_test(v,rtti,cf,OneZero,timeout));
          case CFunction(_,_)  :
            var lines = [
              'In "${rtti.path}.${cf.name}"": test* functions have a particular shape: "Void -> Async", "Void->Void"',
              Std.string(cf.type)
            ];
            __.log().error(lines.join("\n"));
            throw lines.join("\n");
            None;
          default : None;
        };
      }
    );
    var names                = applications.map(f -> f.field.name);
    function name_exists(name){return names.any((n) -> n == name );}
    function depends_on(l:MethodCall,r:MethodCall){
      return l.depends().any(
        (name) -> {
          //trace('${r.test} == $name');
          return r.field.name == name;
        } 
      );
    }
    var ordered_applications = applications.copy().map(
      (application) -> {
        function get_depends(application:MethodCall,?stack:Array<String>):Array<String>{
          //trace(application.field.name);
          stack = __.option(stack).defv([]);
          var dependencies : Array<Couple<String,MethodCall>> = application.depends().map(
            string -> __.couple(string,applications.search((application) -> application.field.name == string))
          ).map(
            __.decouple(
              (string,option:Option<MethodCall>) -> {
                var value = option.resolve(f -> f.failure(ERR(cast 'no dependency $string'))).fudge();
                return __.couple(string,value); 
              }  
            )  
          );
          //trace(dependencies.map(_ -> _.tup()));
          //trace(stack);
          return dependencies.filter(
            (couple) -> !stack.any(name -> couple.fst() == name)
          ).flat_map(
            (couple:Couple<String,MethodCall>) -> couple.snd().depends().is_defined().if_else(
              () -> get_depends(couple.snd(),dependencies.map(cp -> cp.fst())),
              () -> dependencies.map(cp ->cp.fst())
            )
          );
        }
        var dependencies : Array<String> = get_depends(application);
        //trace(dependencies.length);
        //trace(dependencies);
        var depends = dependencies.map(
          (s) -> applications.search(
            (application) -> application.field.name == s
          ).def(
            () -> { throw 'no method named `$s` available on ${application.field.name}}'; null; } 
          )
        );
        return [application].concat(depends);
      }
    );
    function inner_order(l:Array<MethodCall>,r:Array<MethodCall>){
      return l.any(
        (x:MethodCall) -> {
          return r.any(
            (y:MethodCall) -> {
              return x.field.name == y.field.name; 
            }
          );
        }
      );
    }
    //trace(ordered_applications);
    haxe.ds.ArraySort.sort(
      ordered_applications,
      function(lhs:Array<MethodCall>,rhs:Array<MethodCall>){
        return if(inner_order(lhs,rhs)){
          1;
        }else if(inner_order(rhs,lhs)){
          -1;
        }else{
          0;
        }
      }
    );
    //ordered_applications.reverse();
    var reworked_applications  = ordered_applications.map_filter( _ -> _.head());
    //trace(reworked_applications);
    var reordered_applications = ordered_applications.map_filter( _ -> _.head());

    return new TestCaseData(v.asTestCase(),rtti,reordered_applications);
  }
  static public function get_pos(def:Classdef,cf:ClassField):Pos{
    return Position.make(def.file,def.path,cf.name,cf.line);
  }
  static public function get_test(test_case:TestCase,def:Classdef,classfield:ClassField,size,timeout){
    var name      = classfield.name;
    var type_name = std.Type.getClassName(std.Type.getClass(test_case));
    var call      = make_call(test_case,name,def,classfield,size);
    var file      = def.file;
    return new MethodCall(test_case,def,classfield,call,timeout);
  }
  static private function make_call(test_case:TestCase,field_name:String,def:Classdef,cf:ClassField,len:FnType):TestMethodZero{
    var call_zero_zero = ()  -> {
      Reflect.callMethod(test_case,Reflect.field(test_case,field_name),[]);
    }
    var call_zero_one = ()  -> Reflect.callMethod(test_case,Reflect.field(test_case,field_name),[]);
    var call_one      = (v) -> Reflect.callMethod(test_case,Reflect.field(test_case,field_name),[v]);

    function wrap(fn:Void->Option<Async>):Void->Option<Async>{
      return () -> try{
        fn();
      }catch(e:Dynamic){
        __.log().debug(e);
        test_case.raise(E_Test_Dynamic(e),get_pos(def,cf));
        return None;
      }
    }
    // var f0 = () -> { 
    //   var async = Async.wait();
    //   call_one(async);
    //   //trace(async);
    //   return Some(async); 
    // }
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
          var async = Async.wait();
          call_one(async);
          //trace("async ONZERO");
          return Some(async); 
        }); 
      }
    );
    //return TestMethodZero.lift(f0);
  }
}