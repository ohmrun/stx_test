package stx.test;

abstract AsyncResult<T>(Option<T>) from Option<T>{
  @:noUsing static public function lift<T>(self:Option<T>):AsyncResult<T>{
    return self;
  }
  @:noUsing static public function pure<T>(v:T):AsyncResult<T>{
    return lift(Some(v));
  }
  static public function unit<T>():AsyncResult<T>{
    return lift(None);
  }
  public function tap(fn:T->Void):Void{
    this.fold(
      (x) -> fn(x),
      ()  -> {}
    );
  }
  public function use(fn:T->Null<Report<TestFailure>>,?nil:Void->Null<Report<TestFailure>>,?pos:Pos):Report<TestFailure>{
    return this.fold(
      (ok) -> Util.or_res(fn.bind(ok),pos).fold(
        (ok) -> __.option(ok).defv(__.report()),
        (no) -> no.report()
      ),
      ()   -> Util.or_res(__.option(nil).defv(()->__.report())).fold(
        (ok) -> __.option(ok).defv(__.report()),
        (no) -> no.report()
      )
    );
  }
  public function test(val:T->Void,?nil:Void->Null<Report<TestFailure>>,?pos:Pos){
    return this.fold(
      (ok) -> Util.or_res((val.bind(ok):Block).returning(null).prj(),pos).fold(
        (ok) -> __.report(),
        (no) -> no.report()
      ),
      () -> Util.or_res((nil:Block).returning(null).prj(),pos).fold(
        (ok) -> __.report(f -> f.of(NullTestFailure),pos),
        (no) -> no.report()
      )
    );
  }
}