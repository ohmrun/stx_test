package stx.test;

import stx.test.auto.*;
import stx.test.auto.Op;

#if sys
  using stx.Sys;
#end

class Module extends Clazz{
  public function auto():Void{
    (try{
      final val = Spil.parse(__.resource('tests').string());
      final env = std.Sys.getEnv('STX_TEST__SUITE');
      __.log().info('"$env"');

      final spec = stx.test.auto.Reader.get(val).map(
        o -> __.couple(
          o,
          o.specs.search(o -> o.name == env)
            .defv(
              {
                name : "main",
                specs : [],
                op : Exclude
              }
            )
        )
      ).adjust(
        __.decouple(
          (suite:SuiteSpecDef,spec:SpecDef) -> {
            __.log().debug('$suite');
            __.log().debug('$spec');
            return Res.bind_fold(
              suite.cases,
              (n:TestCase,m:Cluster<TestCaseData>) -> {
                final test_case_name = Type.getClassName(Type.getClass(n));
                final spec_ref = spec.specs.search(
                  (class_spec) -> {
                    __.log().trace('${class_spec.path.prj()} ${test_case_name}');
                    return class_spec.path.prj() == test_case_name;
                  }
                );
                __.log().trace('${spec.op}');
                return switch(spec.op){
                  case Include : spec_ref.fold(
                    (x:ClassSpecDef) -> {
                      __.log().debug('$x');
                      final data         = TestCaseLift.get_tests(n,2000);
                      final method_calls = data.method_calls;
                      return __.option(x.methods).fold(
                        methods -> {
                          final next         = Res.bind_fold(
                            method_calls,
                            (n:MethodCall,m:Cluster<MethodCall>) -> {
                              final has_method =  methods.any(
                                (x) -> n.field_name == x
                              );
                              __.log().debug('${has_method} ${n.field_name}');
                              return __.accept(switch(x.op){
                                case Include : has_method ? m.snoc(n) : m;
                                case Exclude : has_method ? m : m.snoc(n);
                              });
                            },
                            []
                          ).map(
                            calls -> data.copy(null,null,calls)
                          );
                          return next;
                        },
                        ()      -> __.accept(data)
                      ).map(x -> m.snoc(x));
                    },
                    () -> __.accept(m)
                  );
                  case Exclude : spec_ref.fold(
                    (_) -> __.accept(m),
                    ()  -> {
                      final data = TestCaseLift.get_tests(n,2000);
                      return __.accept(m.snoc(data));
                    } 
                  );
                }
              },
              []
            );
          }
        )
      );
      trace(spec.point(
        x -> {
          //trace(x);
          new Reporter(new Runner().applyI(x)).enact();
          return __.report();
        }
      ));
    }catch(e:haxe.Exception){
      __.log().fatal(e.details());
    });
  }
  public function run<T:TestCase>(tests:Array<T>,poke:Array<Dynamic>){
    final tests =  
      #if sys
        if (__.sys().env("POKE").is_defined()){
          tests.filter(stx.Test.poke(__,poke));
        }else{
          tests;
        }
      #else 
        tests;
      #end
      
    new Reporter(new Runner().apply(tests)).enact();
  }
}