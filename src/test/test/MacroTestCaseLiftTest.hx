package stx.test.test;

import stx.test.MacroTestCaseLift;

class MacroTestCaseLiftTest extends TestCase{
  public function test_extract(){
    MacroTestCaseLift.get_tests(new TestCaseWithTypeNotation(),6000);
    MacroTestCaseLift.get_tests(new ExampleTestCase(),6000);
  }
}
@stx.test.async
class TestCaseWithTypeNotation extends TestCase{
  public function test_one(){}
}
class ExampleTestCase extends TestCase{
  @stx.test.async
  public function test_has_async_metadata(){

  }
}