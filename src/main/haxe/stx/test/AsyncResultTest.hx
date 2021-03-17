package stx.test;

class AsyncResultTest extends TestCase{
  public function test(async:Async):Void{
   var ft = Future.irreversible(
     (cb) -> cb(true)
   );
   wrap(ft).consume(
    (opt) -> opt.use(
      (b) -> __.report(E_Test_Dynamic("OH NOES"))
    ),
    async
   );
  }
}