package stx.test;

class Reporter extends Clazz{ 
  var stream    : Stream<TestPhaseSum,TestFailure>;
  var printing  : stx.test.reporter.ReportingApi;
  public function new(stream){
    super();
    this.stream   = stream;
    this.printing = #if macro new stx.test.reporter.MacroReporting() #else new stx.test.reporter.RuntimeReporting() #end; 
  }
  private function close(err:Refuse<Dynamic>):Void{
    if(err != null){
      __.log().error(err.toString());
    }
    #if stx.test.shutdown.auto
      #if (sys || nodejs)
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
  public function enact(){
    final p = printing;
    // __.log().debug(_ -> _.show(std.Sys.getEnv('TEST')));
    // __.log().debug(_ -> _.show(std.Sys.getEnv('HOME')));
    // __.log().debug(_ -> _.show(std.Sys.getEnv('STX_TEST__VERBOSE')));
    #if (sys || nodejs)
      final is_verbose = Sys.env('STX_TEST__VERBOS E').is_defined();
      __.log().info('STX_TEST__VERBOSE = $is_verbose');
    #end

    var closed = false;
    function serve(data:TestPhaseSum){
      final l0                    = indenter('');
      final l1                    = indenter(l0);
      final l2                    = indenter(l1);
      final l3                    = indenter(l2);
      final method_call_string_fn = p.method_call_string;
      final test_case_string_fn   = p.test_case_string;
  
      switch(data){
        case TP_Null                              : 
        case TP_Tick(info)                        : p.println(info);
        case TP_StartTestCase(test_case_data)     : p.println(test_case_string_fn(test_case_data),l1);
        case TP_StartTest(method_call)            : p.println(method_call_string_fn(method_call),l2);
        case TP_Failures(xs)                      :
          for(x in xs){
            p.println('<red>${x.toString()}</red>');
          }
        case TP_ReportFatal(err)                  : 
          p.println('<red>${err.toString()}</red>');
          p.println('${err.stack}');
        case TP_Setup(err)
           | TP_Before(err)
           | TP_After(err) 
           | TP_Teardown(err)                     : 
          p.println('<red>${err.toString()}</red>');
        case TP_ReportFailure(assertion,_)        :
          final assertion_string = assertion.outcome().fold(
            s -> s,
            (err:TestFailure) -> __.show(err)
          );
          p.print_status(p.red_cross_on_black,p.fail_string('${assertion_string}'),l3); 
        case TP_ReportTestComplete(method_call)           :
          if(!method_call.has_assertions()){
            p.print_status(p.yellow_question_on_black,p.warn_string('no assertions'),l3);
          }
        case TP_ReportTestCaseComplete(test_case_data)    :
          if(!test_case_data.has_assertions()){
            p.print_status(p.yellow_question_on_black,p.warn_string('no assertions'),l3);
          }           
        case TP_ReportTestSuiteComplete(test_suite)       :
          p.println("_________________________________________________");
          for(test_case_data in test_suite.test_cases){
            __.log().debug(test_case_data.has_assertions());
            if(!test_case_data.has_assertions()){
              p.print_status(p.yellow_question_on_black,p.warn_string('${test_case_data.class_name}'));
            }else if(!test_case_data.has_failures()){
              p.print_status(p.green_tick_on_black,p.ok_string('${test_case_data.class_name}'));
            }else{
              p.print_status(p.red_cross_on_black,p.fail_string('${test_case_data.class_name}'));
            }
            for(method_call in test_case_data.method_calls){
              var status = method_call.has_assertions().if_else(
                () -> method_call.assertions.has_failures().if_else(
                  () -> p.red_cross_on_black,
                  () -> p.green_tick_on_black
                ),
                () -> p.yellow_question_on_black
              );
              p.print_status(status,p.info_string('${method_call.field_name}'));
              for(assertion in method_call.assertions){
                final predicate = 
                  #if (sys || nodejs)
                    Sys.env('STX_TEST__VERBOSE').is_defined();
                  #else
                    false;
                  #end
                if (predicate){
                  assertion.truth.if_else(
                    () -> p.print_status(p.green_tick_on_black,p.ok_string('${assertion}'),l1),
                    () -> {
                      p.print_status(p.red_cross_on_black,p.fail_string('$assertion'),l1);
                      for(stack in __.option(assertion.failure).flat_map(x -> __.option(x.stack))){
                        for(item in stack){
                          p.println(p.fail_string('$item'));
                        }
                      }
                    } 
                  );
                }else{
                  assertion.truth.if_else(
                    () -> {},
                    () -> p.print_status(p.red_cross_on_black,p.fail_string('$assertion'),l1)
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
