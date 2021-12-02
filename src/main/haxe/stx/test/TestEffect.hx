package stx.test;

@:callable abstract TestEffect(Void->Option<TestFailure>) from Void->Option<TestFailure> to Void->Option<TestFailure>{
  @:noUsing static public function unit():TestEffect{
    return () -> Option.unit();
  }
  static public function fromFn(fn:Void->Void):TestEffect{
    return () -> {
      return Util.or_res(fn.fn().returning(Noise).prj()).fold(
        ok -> Option.unit(),
        no -> Option.pure(E_Test_Err(no))
      );
    }
  }
  @:from static public function fromTestFailure(self:TestFailure):TestEffect{
    return () -> {
      return Option.pure(self);
    } 
  }
  @:from static public function fromError<T>(err:Error<T>):TestEffect{
    return () -> {
      return Option.pure(E_Test_Err(err));
    } 
  }
}