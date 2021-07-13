package stx.test;

class Timeout{
  static public function make(timeout:Int):TestResult{
    //__.log().debug('${haxe.Timer.stamp()}, make ${method_call.field.name}');
    var cancelled = false;
    return new Future(
      (cb) -> {
        //__.log().debug('${haxe.Timer.stamp()}, start ${method_call.field.name}');
        haxe.Timer.delay(
          function(){
            //__.log().debug('${haxe.Timer.stamp()}, done ${method_call.field.name}');
            var now = haxe.Timer.stamp(); 
            __.log().debug("DELAYED");
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