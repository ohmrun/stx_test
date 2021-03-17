package stx.unit.test;

class TestCaseLift{
  static public function get_tests<T:TestCase>(v:T){
    var rtti          = Rtti.getRtti(std.Type.getClass(v));
    var fields        = rtti.fields;
    var test_fields   = fields.filter( cf -> cf.name.startsWith('test') );
    var applications  = test_fields.map_filter(
      (cf) -> switch(cf.type){
        case CFunction([],CAbstract('Void',[]))            : 
          Some(get_test(v,rtti,cf,ZeroZero));
        case CFunction([],CAbstract('stx.unit.Async',[]))  : 
          Some(get_test(v,rtti,cf,ZeroOne)
          );
        case CFunction([{ t : CAbstract('stx.unit.Async',[]) } ],CAbstract('Void',[])) :
          Some(get_test(v,rtti,cf,OneZero));
        case CFunction(_,_)  :
          throw 'test* functions have a particular shape: "Void -> Option<Async>" or "Void->Void"\n${cf.name}';
          None;
        default : None;
      }
    );
    var names                = applications.map(
      f -> f.test
    );
    function name_exists(name){
      return names.any(
       (n) -> n == name 
      );
    }
    function depends_on(l:AnnotatedMethodCall,r:AnnotatedMethodCall){
      return l.depends().any(
        (name) -> {
          //trace('${r.test} == $name');
          return r.test == name;
        } 
      );
    }
    var ordered_applications = applications.copy().map(
      (application) -> {
        function get_depends(application:AnnotatedMethodCall,?stack:Array<String>):Array<String>{
          //trace(application.test);
          stack = __.option(stack).defv([]);
          var dependencies : Array<Couple<String,AnnotatedMethodCall>> = application.depends().map(
            string -> __.couple(string,applications.search((application) -> application.test == string))
          ).map(
            __.decouple(
              (string,option:Option<AnnotatedMethodCall>) -> {
                var value = option.fudge(__.fault().any('no dependency $string'));
                return __.couple(string,value); 
              }  
            )  
          );
          //trace(dependencies.map(_ -> _.tup()));
          //trace(stack);
          return dependencies.filter(
            (couple) -> !stack.any(name -> couple.fst() == name)
          ).flat_map(
            (couple:Couple<String,AnnotatedMethodCall>) -> couple.snd().depends().is_defined().if_else(
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
            (application) -> application.test == s
          ).def(
            () -> { throw 'no method named `$s` available on ${application.test}}'; null; } 
          )
        );
        return [application].concat(depends);
      }
    );
    function inner_order(l:Array<AnnotatedMethodCall>,r:Array<AnnotatedMethodCall>){
      return l.any(
        (x:AnnotatedMethodCall) -> {
          return r.any(
            (y:AnnotatedMethodCall) -> {
              return x.test == y.test; 
            }
          );
        }
      );
    }
    //trace(ordered_applications);
    ArraySort.sort(
      ordered_applications,
      function(lhs:Array<AnnotatedMethodCall>,rhs:Array<AnnotatedMethodCall>){
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

  return new TestCaseData(rtti,v.asTestCase(),reordered_applications);
  }
  static public function get_pos(def:Classdef,cf:ClassField):Pos{
    return Position.make(def.file,def.path,cf.name,cf.line);
  }
  static public function get_test(test_case:TestCase,def:Classdef,classfield:ClassField,size){
    var name      = classfield.name;
    var type_name = std.Type.getClassName(std.Type.getClass(test_case));
    var call      = make_call(test_case,name,def,classfield,size);
    var file      = def.file;
    return new AnnotatedMethodCall(test_case,file,type_name,name,call,classfield);
  }
  static private function make_call(test_case:TestCase,field_name:String,def:Classdef,cf:ClassField,len:FnType):TestMethodZero{
    var call_zero_zero = ()  -> {
      Reflect.callMethod(test_case,Reflect.field(test_case,field_name),[]);
    }
    var call_zero_one = ()  -> Reflect.callMethod(test_case,Reflect.field(test_case,field_name),[]);
    var call_one  = (v) -> Reflect.callMethod(test_case,Reflect.field(test_case,field_name),[v]);

    function wrap(fn:Void->Option<Async>):Void->Option<Async>{
      return () -> try{
        fn();
      }catch(e:Dynamic){
        test_case.raise(E_Test_Dynamic(e),get_pos(def,cf));
        return None;
      }
    }
    var f0 = () -> { 
      var async = Async.wait();
      call_one(async);
      //trace(async);
      return Some(async); 
    }
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
          //trace("_____");
          var async = Async.wait();
          call_one(async);
          //trace(async);
          return Some(async); 
        }); 
      }
    );
    //return TestMethodZero.lift(f0);
  }
}