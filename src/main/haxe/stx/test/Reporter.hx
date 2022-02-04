package stx.test;

#if (sys || hxnodejs)
  using stx.Sys;
#end
class Reporter extends Clazz{ 
  var stream : Stream<TestPhaseSum,TestFailure>;
  public function new(stream){
    super();
    this.stream = stream;
  }
  private function close(err:Rejection<Dynamic>):Void{
    if(err != null){
      __.log().error(err.toString());
    }
    #if stx.test.shutdown.auto
      #if (sys || hxnodejs)
        __.log().debug('shutting down app...');
        if(err == null){
          std.Sys.exit(0);
        }else{
          std.Sys.exit(-1);
        }
      #else
        #error
      #end
    #end
  }
  function indenter(indent){
    return '$indent\t';
  }
  public var green_tick(get,null):String;
  private function get_green_tick():String{
    return '<green>✓</green>';
  }
  public var green_tick_on_black(get,null):String;
  private function get_green_tick_on_black():String{
    return '<bg_black>$green_tick</bg_black>';
  }
  public var red_cross(get,null):String;
  private function get_red_cross():String{
    return '<red>✗</red>';
  }
  public var red_cross_on_black(get,null):String;
  private function get_red_cross_on_black():String{
    return '<bg_black>$red_cross</bg_black>';
  }
  public var yellow_question_on_black(get,null):String;
  private function get_yellow_question_on_black():String{
    return '<bg_black><yellow>?</yellow></bg_black>';
  }
  public var bad(get,null):String;
  private function get_bad():String{
    return red_cross_on_black;
  }
  public var good(get,null):String;
  private function get_good():String{
    return green_tick_on_black;
  }
  private inline function println(str:String,indent:String = ""):Void{
    Console.log('${indent}${str}');
  }
  private inline function print_status(icon:String,str:String,indent:String = ""):Void{
    Console.log('$icon ${indent}${str}');
  }
  public function enact(){
    // __.log().debug(_ -> _.show(std.Sys.getEnv('TEST')));
    // __.log().debug(_ -> _.show(std.Sys.getEnv('HOME')));
    // __.log().debug(_ -> _.show(std.Sys.getEnv('STX_TEST__VERBOSE')));
    //final is_verbose = __.sys().env('STX_TEST__VERBOSE').is_defined();
    //__.log().info('STX_TEST__VERBOSE = $is_verbose');
  
    var closed = false;
    function serve(data:TestPhaseSum){
      final l0                    = indenter('');
      final l1                    = indenter(l0);
      final l2                    = indenter(l1);
      final l3                    = indenter(l2);
      final method_call_string_fn = 
        (test:MethodCall)           -> '<blue>${test.clazz.path}::${test.field.name}</blue>';
      final test_case_string_fn   = 
        (test_case:TestCaseData)    -> '<light_white>${test_case.clazz.path}</light_white>';
  
      switch(data){
        case TP_Null                              : 
        case TP_Tick(info)                        : println(info);
        case TP_StartTestCase(test_case_data)     : println(test_case_string_fn(test_case_data),l1);
        case TP_StartTest(method_call)            : println(method_call_string_fn(method_call),l2);
        case TP_ReportFatal(err)                  : 
          println('<red>${err.toString()}</red>');
          println('${err.stack}');
        case TP_Setup(err)
           | TP_Before(err)
           | TP_After(err) 
           | TP_Teardown(err)                     : 
          println('<red>${err.toString()}</red>');
        case TP_ReportFailure(assertion,_)        :
          final assertion_string = assertion.outcome().fold(
            s -> s,
            (err:TestFailure) -> __.show(err)
          );
          print_status(red_cross_on_black,'<red>${assertion_string}</red>',l3); 
        case TP_ReportTestComplete(method_call)           :
          if(!method_call.has_assertions()){
            print_status(yellow_question_on_black,'<yellow>no assertions</yellow>',l3);
          }
        case TP_ReportTestCaseComplete(test_case_data)    :
          if(!test_case_data.has_assertions()){
            print_status(yellow_question_on_black,'<yellow>no assertions</yellow>',l3);
          }           
        case TP_ReportTestSuiteComplete(test_suite)       :
          println("_________________________________________________");
          for(test_case_data in test_suite.test_cases){
            __.log().debug(test_case_data.has_assertions());
            if(!test_case_data.has_assertions()){
              print_status(yellow_question_on_black,'<yellow>${test_case_data.clazz.path}</yellow>');
            }else if(!test_case_data.has_failures()){
              print_status(green_tick_on_black,'<green>${test_case_data.clazz.path}</green>');
            }else{
              print_status(red_cross_on_black,'<red>${test_case_data.clazz.path}</red>');
            }
            for(method_call in test_case_data.method_calls){
              var status = method_call.has_assertions().if_else(
                () -> method_call.assertions.has_failures().if_else(
                  () -> red_cross_on_black,
                  () -> green_tick_on_black
                ),
                () -> yellow_question_on_black
              );
              print_status(status,'<blue>${method_call.field.name}</blue>');
              for(assertion in method_call.assertions){
                final predicate = 
                  #if sys
                    __.sys().env('STX_TEST__VERBOSE').is_defined();
                  #else
                    false;
                  #end
                if (predicate){
                  assertion.truth.if_else(
                    () -> print_status(green_tick_on_black,'<green>${assertion}</green>',l1),
                    () -> {
                      print_status(red_cross_on_black,'<red>$assertion</red>',l1);
                      println('${__.option(assertion.failure).flat_map(x -> __.option(x.stack)).defv(null)}');
                    } 
                  );
                }else{
                  assertion.truth.if_else(
                    () -> {},
                    () -> print_status(red_cross_on_black,'<red>$assertion</red>',l1)
                  );
                }
              }
            }
          }
          if(!test_suite.is_clean()){
            close(__.fault().explain(_ -> _.e_suite_failed()));
          }else{
            close(null);
          }

          closed = true;
      }
    }
    this.stream.handle(
      function(chunk:Chunk<TestPhaseSum,TestFailure>):Void { 
        chunk.fold(
          val -> serve(val),
          end -> if(!closed){
            close(end);
          },
          () -> {}
        );
      } 
    ); 
  }
}
