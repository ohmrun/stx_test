package stx.test;

@:callable abstract TestEffect(Void->Cluster<TestFailure>) from Void->Cluster<TestFailure> to Void->Cluster<TestFailure>{
  @:noUsing static public function unit():TestEffect{
    return () -> Cluster.unit();
  }
  @:noUsing static public function lift(self:Void->Cluster<TestFailure>):TestEffect{
    return (self:TestEffect);
  }
  @:noUsing static public function fromCluster(self:Cluster<TestFailure>):TestEffect{
    return lift(() -> self);
  }
  static public function fromFn(fn:Void->Void,?pos:Pos):TestEffect{
    return () -> {
      return Util.or_res(fn.fn().returning(Noise).prj(),pos).fold(
        ok -> Cluster.unit(),
        no -> Cluster.pure(E_Test_Refuse(no))
      );
    }
  }
  @:from static public function fromTestFailure(self:TestFailure):TestEffect{
    return () -> {
      return Cluster.pure(self);
    } 
  }
  @:from static public function fromError<T>(err:Error<T>):TestEffect{
    return () -> {
      return Cluster.pure(E_Test_Refuse(err.except()));
    } 
  }
  @:from static public function fromRefuse<T>(err:Refuse<T>):TestEffect{
    return () -> {
      return Cluster.pure(E_Test_Refuse(err));
    } 
  }
  public function concat(that:TestEffect){
    return () -> this().concat(that());
  }
}