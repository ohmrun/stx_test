package stx.test.test;

class SynchronousErrorTest extends TestCase{
  public function test(){
    throw "caught";
  }
  public function test_nothing(){
    
  }
}