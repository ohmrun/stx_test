package stx.unit.test;

class Timeout{
  static public function make(timeout:Int):TestResult{
    //trace('${haxe.Timer.stamp()}, make ${method_call.field.name}');
    var cancelled = false;
    return new Future(
      (cb) -> {
        //trace('${haxe.Timer.stamp()}, start ${method_call.field.name}');
        haxe.Timer.delay(
          function(){
            //trace('${haxe.Timer.stamp()}, done ${method_call.field.name}');
            var now = haxe.Timer.stamp(); 
            //trace("DELAYED");
            if(!cancelled){
              cb(
                TestEffect.fromTestFailure(TestTimedOut(timeout))
              );
            }
          }
        ,timeout);
        var cbl = function(){
          //__.log().debug('cancelled');
          cancelled = true;
        }
        return cbl;
      }
    );
  }
}