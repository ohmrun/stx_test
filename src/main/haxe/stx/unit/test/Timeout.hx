package stx.unit.test;

class Timeout{
  static public function make(method_call:MethodCall,timeout:Int){
    trace('${haxe.Timer.stamp()}, make ${method_call.field.name}');
    var cancelled = false;
    return new Future(
      (cb) -> {
        trace('${haxe.Timer.stamp()}, start ${method_call.field.name}');
        haxe.Timer.delay(
          function rec(){
            //trace('${haxe.Timer.stamp()}, done ${method_call.field.name}');
            var now = haxe.Timer.stamp(); 
            //trace("DELAYED");
            if(!cancelled){
              if(now > method_call.timestamp + (timeout/1000)){
                @:privateAccess method_call.object.__assertions.push(
                  Assertion.make(false,
                    'timeout'
                    ,TestTimedOut(timeout)
                    ,method_call.position()
                  )
                );
                cb(
                  ()->{}
                );
              }else{
                haxe.Timer.delay(rec,500);
              }
            }
          }
        ,500);
        var cbl = function(){
          __.log().debug('cancelled');
          cancelled = true;
        }
        return cbl;
      }
    );
  }
}