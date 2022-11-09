package stx.test;

@:rtti class TestCase extends Assert{
  private function __stx__tests(timeout){
    return TestCaseLift.get_tests(this,timeout);
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
        }catch(e:Error<Dyn>){
          __.log().debug('$e');
          this.error(e,pos);
          cb(__.triple(pos,this,AsyncResult.unit()));
          null;
        }catch(e:haxe.Exception){
          __.log().debug('$e');
          this.exception(e,pos);
          cb(__.triple(pos,this,AsyncResult.unit())); 
          null;
        }
      }
    ));
  }
}

