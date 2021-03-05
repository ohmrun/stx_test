package stx.test;

class Suite extends massive.unit.TestSuite{
  final var tests : Array<Class<Dynamic>>;
  public function new(){
    for(clazz in tests) add(clazz);
  }
}