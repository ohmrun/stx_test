package stx.test.test;

class TestTest extends TestCase{
 
  // public function test_raise(){
  //   throw 'NONR';
  // }
  // public function test_asynchronous_raise(){
  //   var async = Async.wait();

  //   haxe.Timer.delay(
  //     () -> {
  //       //throw "NOOOOO";//NOT handled, should bug out
  //       async.done();
  //     },
  //     300
  //   );
  //   return async;
  // }
  public function test_asynchonous_captured_raise(){
    var ft = new Future(
      (cb) -> {
        // haxe.Timer.delay(
        //   () -> {
        //     throw "JBSDFJB";
        //     cb(true);
        //   },
        //   300
        // );
        throw("JUB");
        cb(true);
        return null;
      }
    );
    var async = Async.wait();
    var ft    = ft;//this.capture(async.wrap(ft));
        ft.handle(
          (x)  -> {
            trace(x);
          }
        );
    return async;
  }
  public function test_assertion(){
    pass();
  }
}