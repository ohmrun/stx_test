package stx.unit.test;

class Timeout{
  static public function make(method_call:MethodCall,timeout:Int){
    trace('${haxe.Timer.stamp()}, make ${method_call.test}');
    var cancelled = false;
    return new Future(
      (cb) -> {
        trace('${haxe.Timer.stamp()}, start ${method_call.test}');
        haxe.Timer.delay(
          function rec(){
            //trace('${haxe.Timer.stamp()}, done ${method_call.test}');
            var now = haxe.Timer.stamp(); 
            //trace("DELAYED");
            if(!cancelled){
              if(now > method_call.timestamp + (timeout/1000)){
                @:privateAccess method_call.data.__assertions.push(
                  Assertion.make(false,
                    'timeout',TestTimedOut(timeout),Position.make(method_call.file,method_call.type,method_call.test,null,null)
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
          cancelled = true;
        }
        return cbl;
      }
    );
  }
}