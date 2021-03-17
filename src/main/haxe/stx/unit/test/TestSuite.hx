package stx.unit.test;

class TestSuite{
  public final cases : Array<TestCase>;
  public final data  : Array<TestCaseData>;
  public function new(cases,data){
    this.cases = cases;
    this.data  = data;
  } 
  public function is_clean(){
    var clean = true;
    for(tcd in data){
      if(tcd.has_failures()){
        clean = false;
        break;
      }
    }
    return clean;
  }
}