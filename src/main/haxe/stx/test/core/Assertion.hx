package stx.test.core;

typedef AssertionDef = {
  var ?explanation  : String;
  var ?failure      : TestFailure;
  var truth         : Bool;
  var pos           : Pos;
}
@:forward abstract Assertion(AssertionDef) from AssertionDef to AssertionDef {
  @:noUsing static public function make(truth:Bool,explanation:String,?failure:TestFailure,pos:Pos){
    return new Assertion({
      truth         : truth,
      explanation   : explanation,
      failure       : __.option(failure).def(() -> TestFailedBecause(explanation)),
      pos           : pos
    });
  }
  public function outcome():Outcome<String,TestFailure>{
    return this.truth ? __.success(this.explanation) : __.failure(this.failure);
  }
  public function toString(){
    return outcome().fold(
      ok  -> ok,
      e   -> __.show(e)
    );
  }
  public function new(self) this = self;
}