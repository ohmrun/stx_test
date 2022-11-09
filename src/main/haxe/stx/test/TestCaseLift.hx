package stx.test;

import haxe.rtti.Meta;

class TestCaseLift{
  static public function get_tests<T:TestCase>(v:T,timeout:Int){
    final clazz             = std.Type.getClass(v);
    //trace(clazz);
    final class_name        = std.Type.getClassName(clazz);
    //trace(class_name);
    final type_meta         = Meta.getType(clazz);
    final type_is_async     = Reflect.hasField(type_meta,"stx.test.async");

    final fields            = std.Type.getInstanceFields(clazz);
    final fields_meta       = Meta.getFields(clazz);

    __.log().debug(_ -> _.pure(fields));
    
    var test_fields         = fields.filter( cf -> cf.startsWith('test') );
    var applications        = test_fields.map_filter(
      (field_name) -> {
        final field_meta      = __.option(Reflect.field(fields_meta,field_name));
        final field_is_async  = field_meta.map( (o:Dynamic) -> Reflect.hasField(o,'stx.test.async')).defv(false);
        return if(type_is_async || field_is_async ){
          Some(get_test(v,class_name,field_name,OneZero,timeout));
        }else{
          Some(get_test(v,class_name,field_name,ZeroZero,timeout));
        }
      }
    );
    var names                = applications.map(f -> f.field_name);
    function name_exists(name){return names.any((n) -> n == name );}
    function depends_on(l:MethodCall,r:MethodCall){
      return l.depends().any(
        (name) -> {
          //trace('${r.test} == $name');
          return r.field_name == name;
        } 
      );
    }
    var ordered_applications = applications.copy().map(
      (application) -> {
        function get_depends(application:MethodCall,?stack:Array<String>):Array<String>{
          //trace(application.field_name);
          stack = __.option(stack).defv([]);
          var dependencies : Array<Couple<String,MethodCall>> = application.depends().map(
            string -> __.couple(string,applications.search((application) -> application.field_name == string))
          ).map(
            __.decouple(
              (string,option:Option<MethodCall>) -> {
                var value = option.resolve(f -> f.explain(_ -> _.e_dependency_not_found('$string'))).fudge();
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
            (application) -> application.field_name == s
          ).def(
            () -> { throw 'no method named `$s` available on ${application.field_name}}'; null; } 
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
              return x.field_name == y.field_name; 
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

    return new TestCaseData(v.asTestCase(),class_name,reordered_applications);
  }
  static public function get_test(test_case:TestCase,class_name:String,field_name:String,size,timeout){
    var type_name = std.Type.getClassName(std.Type.getClass(test_case));
    var call      = make_call(test_case,field_name,size);
    return new MethodCall(test_case,class_name,field_name,call,timeout);
  }
  static private function make_call(test_case:TestCase,field_name:String,len:FnType):TestMethodZero{
    var call_zero_zero = ()  -> {
      Reflect.callMethod(test_case,Reflect.field(test_case,field_name),[]);
    }
    var call_zero_one = ()  -> Reflect.callMethod(test_case,Reflect.field(test_case,field_name),[]);
    var call_one      = (v) -> Reflect.callMethod(test_case,Reflect.field(test_case,field_name),[v]);

    function wrap(fn:Void->Option<Async>):Void->Option<Async>{
      return () -> try{
        fn();
      }catch(e:haxe.Exception){
        __.log().debug('$e');
        test_case.raise(e);
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