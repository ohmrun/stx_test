package stx.test;

class DependsTest extends TestCase{
  @depends("test_2")
  public function test_1(){
    pass();
  }
  @depends("test_3")
  public function test_2(){
    pass();
  }
  public function test_3(){
    pass();
  }
  @depends("test_2","test_3")
  public function test_4(){
    pass();
  }
}