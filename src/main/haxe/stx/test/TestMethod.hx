package stx.test;

enum TestMethodSum {
  TMZero(m:TestMethodZero);
  TMOne(m:TestMethodOne);
}

abstract TestMethod(TestMethodSum) to TestMethodSum{
  public function  new(self) this = self;
  @:noUsing static public function lift(self){
    return new TestMethod(self);
  }
  static public function fromTestMethodZero(self:TestMethodZero):TestMethod{
    return lift(TMZero(self));
  }
  static public function fromTestMethodOne(self:TestMethodOne):TestMethod{
    return lift(TMOne(self));
  }
  public function prj():TestMethodSum{
    return this;
  }
}