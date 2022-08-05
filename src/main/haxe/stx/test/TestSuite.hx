package stx.test;

class TestSuite{
  public final test_cases  : Cluster<TestCaseData>;
  public function new(test_cases){
    this.test_cases = test_cases;
  } 
  public function is_clean(){
    var clean = true;
    for(tcd in test_cases){
      if(tcd.has_failures()){
        clean = false;
        break;
      }
    }
    return clean;
  }
}