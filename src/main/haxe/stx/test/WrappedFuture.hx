package stx.test;

abstract WrappedFuture<T>(Future<Triple<Pos,TestCase,AsyncResult<T>>>) from Future<Triple<Pos,TestCase,AsyncResult<T>>>{
  public function new(self) this = self;
  public function consume(cb:AsyncResult<T>->Null<Report<TestFailure>>,?async:Async){
    var link = this.handle(
      (x) -> {
        Util.or_res(
          () -> {
            __.option(cb(x.thd())).defv(Report.unit()).fold(
              (e) -> {
                var str = __.show(e.data);
                //__.log().debug('report ${str}');
                x.snd().error(e,x.fst());
              },
              ()  -> {}
            );
            return Nada;
          }
        ).fold(
          (ok)  -> {},
          (no) -> x.snd().error(__.fault(x.fst()).of(E_Test_Refuse(no)),x.fst())
        );
        if(async != null){
          async.done();
        }
      }
    );
  }
  @:noUsing static public function lift<T>(self:Future<Triple<Pos,TestCase,AsyncResult<T>>>):WrappedFuture<T>{
    return new WrappedFuture(self); 
  }
  public function prj():Future<Triple<Pos,TestCase,AsyncResult<T>>> return this;
  private var self(get,never):WrappedFuture<T>;
  private function get_self():WrappedFuture<T> return this;
}