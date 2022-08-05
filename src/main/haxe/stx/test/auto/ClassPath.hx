package stx.test.auto;

abstract ClassPath(String){
  function new(self) this = self;
  @:noUsing static public function make(self:String):ClassPath{
    return new ClassPath(self);
  }
  public function prj(){
    return this;
  }
}