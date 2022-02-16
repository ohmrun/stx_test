package stx.test.core;

class Errors{
  static public function e_dependency_not_found(digests:Digests,name):Digest{
    return new EDependencyNotFound(name);
  }
  static public function e_suite_failed(digests:Digests):Digest{
    return new ESuiteFailed();
  }
}
class EDependencyNotFound extends Digest{
  public function new(name){
    super("01FRQ8G5NCTBY7YV908Y41NZPP",'Dependency $name not found');
  }
}
class ESuiteFailed extends Digest{
  public function new(){
    super("01FRQ8KHEHGBBSTN89XC492A0E","TestSuite failed");
  }
}