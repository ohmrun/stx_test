package stx.test.test;

class UseAsyncTest extends TestCase{
  public function test_bring(async:Async){
    trace("JERJ");
    pass();
    async.done();
  }
  public function test_timeout(async:Async){
    trace("JERJ");
    pass();
  }
}