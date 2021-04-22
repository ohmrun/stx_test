package stx.test;

class SynchronousErrorTest extends TestCase{
  public function test(){
    throw "caught";
  }
}