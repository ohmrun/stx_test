package stx.test.test;

@stx.test.async
class UseAsyncTest extends TestCase{
  public function _test_bring(async:Async){
    trace("JERJ");
    pass();
    async.done();
  }
  // TODO report timeout
  public function test_timeout(async:Async){
    trace("JERJ");
    pass();
  }
}