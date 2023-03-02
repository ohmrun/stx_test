
package stx.test.test;

class AsyncResultTest extends TestCase{
  public function test(async:Async):Void{
   var ft = Future.irreversible(
     (cb) -> cb(true)
   );
   wrap(ft).consume(
    (opt) -> opt.use(
      (b) -> __.report(f -> f.explain(_ -> new EOhNoes()))
    ),
    async
   );
  }
}
class EOhNoes extends Digest{
  public function new(){
    super("01FRQ9BQW9QG10YE7TFRKQ9J7M","OH NOES");
  }
}