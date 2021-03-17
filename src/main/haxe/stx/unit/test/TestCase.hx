package stx.unit.test;

@:rtti class TestCase extends Assert{
  private function __stx__tests(){
    return TestCaseLift.get_tests(this);
  }
  public function __setup():Option<Async>{
    return None;
  }
  public function __teardown():Option<Async>{
    return None;
  }
  public function __before():Option<Async>{
    return None;
  }
  public function __after():Option<Async>{
    return None;
  }
  public function asTestCase():TestCase{
    return this;
  }
  public function wrap<T>(future:Future<T>,?pos:Pos):WrappedFuture<T>{
    return WrappedFuture.lift(new Future(
      (cb) -> {
        return try{
          future.handle(
            (v) -> {
              cb(__.triple(pos,this,AsyncResult.pure(v)));
            }
          );
        }catch(e:Err<Dyn>){
          this.error(e,pos);
          cb(__.triple(pos,this,AsyncResult.unit()));
          null;
        }catch(e:Dynamic){
          this.error(__.fault(pos).of(E_Test_Dynamic(e)),pos);
          cb(__.triple(pos,this,AsyncResult.unit())); 
          null;
        }
      }
    ));
  }
}

