package stx.unit.test;

class Runner{
  public final timeout : Int;
  public function new(?timeout=6000){
    this.timeout = timeout;
  }
  public function apply<T:TestCase>(cases:Array<T>){
    var normalized : Array<TestCase> = cases.map(x -> x.asTestCase());
    var a = __.nano().Ft().bind_fold(
      normalized,
      (test_case:TestCase,memo:Array<TestCaseData>) -> {
        var test_case_data = @:privateAccess test_case.__stx__tests();
        var setup          = Async.reform(test_case.__setup());

        var ft = __.nano().Ft().bind_fold(
          test_case_data.data,
          (next:AnnotatedMethodCall,memo:Array<MethodCall>) -> {
            //trace(next.test);
            var before = Async.reform(test_case.__before());
            return before.flatMap(
              (_) -> {
                return try{
                  var result = next.call();
                  switch(result){
                    case None                 : Future.irreversible((cb -> cb(()->{})));
                    case Some(ft)             : ft.asFuture();
                    case null                 : Future.irreversible((cb -> cb(()->{})));
                  }
                }catch(e:Err<Dynamic>){
                  Future.irreversible(
                    (cb) -> {
                      cb(()->{next.data.error(e);});
                    }
                  );
                }catch(e:Dynamic){
                  Future.irreversible(  
                    (cb) -> {
                      cb(() -> {
                        next.data.error(__.fault().of(E_Test_Dynamic(e)));
                      });
                    }
                  );
                }
            }).first(
                Timeout.make(next,next.timeout().defv(timeout))).map(
                 (cb) -> {
                  cb();
                  return memo.snoc(next);
                }
            ).flatMap(
              (res) -> {
                var after = Async.reform(test_case.__after());
                return after.map(
                  (_) -> res
                );
              }
            );
          }
          ,[]
        ).map(
          x -> Noise
        );
        return ft.flatMap(
          (x) -> {
            var teardown  = Async.reform(test_case.__teardown());
            return teardown.map(_ -> x);
          }
        ).map((_) -> memo.snoc(test_case_data));
      },
      []
    );
    //$type(a);
    return a.map(
      (tcd) -> return new TestSuite(normalized,tcd)
    );
  } 
}