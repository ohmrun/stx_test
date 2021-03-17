package stx.test;

class TestTestWorking extends TestCase{
  public function test_2(){
    var async = Async.wait();

    haxe.Timer.delay(
      () -> {
        async.done();
      },
      300
    );
    return async;
  }
  public function test_0(){
    pass();
  }
  public function test_1(){
    equals(1,1);
  }
}