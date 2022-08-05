package stx.test.auto;

class Index{
  public final path : String;
  public final data : TestSuite;
  public function new(path,data){
    this.path = path;
    this.data = data;
  }
}