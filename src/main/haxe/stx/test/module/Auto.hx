package stx.test.module;

import stx.fail.TestFailure.TestFailureSum;

using stx.Nano;
using stx.Parse;
using eu.ohmrun.Pml;

import stx.test.auto.*;
import stx.test.auto.Op;

import eu.ohmrun.pml.Extract.*;

private enum AutoSpecToken{
  AIndeces(array:Cluster<String>);
  AClassSpec(typename:String,?op:Op,?tests:Cluster<String>);
  ASuiteSpec(name:String,op:Op,classes:Cluster<AutoSpecToken>);
}
class Auto{
  static public function main(){
    return imbibe(indeces().and(suite_spec().one_many()),'main').then(
      __.decouple(
        (tI,tII:Cluster<AutoSpecToken>) -> switch(tI){
          case AIndeces(arr) : 
            Res.bind_fold(
              tII,
              (next, memo:Cluster<SpecDef>) -> switch(next){
                case ASuiteSpec(name,op,classes) : 
                  Res.bind_fold(
                    classes,
                    (next,memo:Cluster<ClassSpecDef>) -> switch(next){
                      case AClassSpec(tname,op,tests) : __.accept(memo.snoc({
                        path    : ClassPath.make(tname),
                        op      : op,
                        methods : tests
                      }));
                      default : __.reject(f -> f.of(E_Test_BadSpec));
                    },
                    [].imm()
                  ).map(
                    (x:Cluster<ClassSpecDef>) -> {
                      name  : name,
                      specs : x,
                      op    : op
                    }
                  ).map(
                    memo.snoc
                  );
                default       : __.reject(f -> f.of(E_Test_BadSpec));
              },
              []
            ).flat_map(
              (specs:Cluster<SpecDef>) -> {
                return Res.bind_fold(
                  arr,
                  (next,memo:Cluster<TestCase>) -> {
                    return resolve_index(next).map(
                      memo.concat
                    );
                  },
                  [].imm()
                ).map(
                  cases -> ({
                    cases : cases,
                    specs : specs
                  }:SuiteSpecDef)
                );
              }
            );
          default             : __.reject(f -> f.of(E_Test_NoIndeces));
        }
      )
    );
  }
  static public function reply(){
    final v       = __.resource('tests').string();
    final vI      = __.pml().parseI()(v.reader()).toChunk();
    return vI.fold(
      x -> return stx.test.module.Auto.main().apply([x].reader()).toRes().fold(
        ok -> ok.fold(
          o   -> __.accept(o),
          ()  -> __.reject(f -> f.of(E_Test_BadSpec))
        ),
        e -> __.reject(e.errate(eI -> TestFailure.fromParseFailure(eI)))
      ),
      e   -> __.reject(e.errate(eI -> TestFailure.fromParseFailure(eI))),
      ()  -> __.reject(f -> f.of(E_Test_BadSpec)) 
    ).flat_map(x -> x);
  }
  static public function indeces(){
    return imbibe(symbol('indeces')._and(wordish().one_many()).then(AIndeces),'main');
  }
  static public function suite_spec(){
    return imbibe(
      wordish()
      .and(op())
      .and(imbibe(class_spec_list(),'class_spec_list'))
      .then(
        x -> ASuiteSpec(x.fst().fst(),x.fst().snd(),x.snd())
      )
      ,'suite_spec'
    ).or(
      imbibe(
        wordish()
        .and(op())
        .and(wordish().then(x -> AClassSpec(x)).one_many())
        .then(
          x -> ASuiteSpec(x.fst().fst(),x.fst().snd(),x.snd())
        ),
        'suite_spec'
      )
    );
  }
  static public function class_spec_list(){
    return imbibe(class_spec_n(),'class_spec_n').or(class_spec_zero()).one_many();
  }
  static public function class_spec_zero(){
    return wordish().then(x -> AClassSpec(x));
  }
  static public function class_spec_n(){
    return wordish().and(op()).and(wordish().one_many()).then(x -> AClassSpec(x.fst().fst(),x.fst().snd(),x.snd()));
  }
  static public function include(){
    return symbol('include').then(_ -> Include);
  }
  static public function exclude(){
    return symbol('exclude').then(_ -> Exclude);
  }
  static public function  op(){
    return include().or(exclude());
  }
  static public function resolve_index(self:String):Res<Cluster<TestCase>,TestFailure>{
    final clazz = std.Type.resolveClass(self);
    return (clazz == null).if_else(
      () -> __.reject(__.fault().of(E_Test_AutoClassNotFound(self))),
      () -> std.Type.getClassFields(clazz).search(
        x -> x == 'tests'
      ).resolve(
        f -> f.of(E_Test_AutoFieldNotFound('${self}.tests()'))
      ).adjust(
        x -> return try{
          final tests : Cluster<TestCase> = Reflect.field(clazz,'tests')();
          __.accept(tests);
        }catch(e:haxe.Exception){
          __.log().debug('$e');
          __.reject(__.fault().explain(e.explain()));
        }
      )
    );
  }
}