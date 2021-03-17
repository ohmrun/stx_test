package stx.unit.test;

class Reporter extends Clazz{ 
  public function report(data:TestSuite){
    function indenter(indent){
      return '$indent\t';
    }
    var green_tick = '<green>✓</green>';
    var gtob       = '<bg_black>$green_tick</bg_black>';

    var red_cross  = '<red>✗</red>';
    var rtob       = '<bg_black>$red_cross</bg_black>';
    var l0       = indenter('');
    var l1       = indenter(l0);

    var tests     = 0;
    var warnings  = 0;
    var errors    = 0;
    var println   = Sys.println;
    for (tcd in data.data){
      //trace(tcd.has_failures());
      //trace(@:privateAccess tcd.val.__assertions);
      //trace(@:privateAccess tcd.val.__assertions.failures);
      final method_call_string_fn = (test:AnnotatedMethodCall) -> '<blue>${test.type}::${test.test}</blue>';
      if(tcd.has_failures()){
        Console.log('$rtob <light_white>${tcd.type.path}</light_white>');
        for(test in tcd.data){
          
          var method_call_string = method_call_string_fn(test);

          var failures = test.assertions.failures;
          //trace(@:privateAccess tcd.val.__assertions);
          //trace(test.assertions);
          if(failures.length > 0){   
            Console.log('${l0}${method_call_string}');
            for(failure in failures){
              Console.log('$rtob <red>${l1}${failure}</red>');
            }
          }else if(test.assertions.length == 0){
            Console.log('${l0}${method_call_string}');
            Console.log('${l1}<yellow>no assertions made</yellow>');
          }else{
            Console.log('$gtob ${l0}${method_call_string} ');
          }
        }
      }else{
        Console.log('$gtob  <light_white>${tcd.type.path}</light_white> ');
        for(test in tcd.data){
          var method_call_string = method_call_string_fn(test);
          Console.log('$gtob ${l0}${method_call_string} ');
        }
      }
    }
  }
}