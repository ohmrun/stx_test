package stx.unit.test;

@:using(stx.lift.ArrayLift)
@:forward abstract Assertions(Array<Assertion>) from Array<Assertion> to Array<Assertion>{
  public var failures(get,never):Array<Err<TestFailure>>;
  private function get_failures():Array<Err<TestFailure>>{
    return this.map_filter(
      (x) -> x.res().fold(_ -> None,Some)
    );
  }
}