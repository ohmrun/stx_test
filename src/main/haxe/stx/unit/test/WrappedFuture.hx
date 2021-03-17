package stx.unit.test;

abstract WrappedFuture<T>(Future<Triple<Pos,TestCase,AsyncResult<T>>>) from Future<Triple<Pos,TestCase,AsyncResult<T>>>{
  public function new(self) this = self;
  public function consume(cb:AsyncResult<T>->Null<Report<TestFailure>>,?async:Async){
    var link = this.handle(
      (x) -> {
        try{
          final report = __.option(cb(x.thd())).defv(Report.unit());
                report.fold(
                  (e) -> {
                    var str = __.show(e.data);
                    trace('report ${str}');
                    x.snd().error(e,x.fst());
                  },
                  ()  -> {}
                );
        }catch(e:Err<Dynamic>){
          x.snd().error(__.fault(x.fst()).of(E_Test_Err(e)),x.fst());
        }catch(e:Dynamic){
          x.snd().error(__.fault(x.fst()).of(E_Test_Dynamic(e)),x.fst());
        }
        if(async != null){
          async.done();
        }
      }
    );
  }
  static public function lift<T>(self:Future<Triple<Pos,TestCase,AsyncResult<T>>>):WrappedFuture<T>{
    return new WrappedFuture(self); 
  }
  public function prj():Future<Triple<Pos,TestCase,AsyncResult<T>>> return this;
  private var self(get,never):WrappedFuture<T>;
  private function get_self():WrappedFuture<T> return this;
}