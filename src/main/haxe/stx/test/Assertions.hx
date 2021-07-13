package stx.test;

@:using(stx.lift.ArrayLift)
@:forward abstract Assertions(Array<Assertion>) from Array<Assertion> to Array<Assertion>{
  public var failures(get,never):Array<TestFailure>;
  private function get_failures():Array<TestFailure>{
    return this.map_filter(
      (x) -> x.outcome().fold(_ -> None,Some)
    );
  }
  public function has_failures(){
    return failures.is_defined();
  }
  
}