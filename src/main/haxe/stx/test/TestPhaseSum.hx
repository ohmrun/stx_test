package stx.test;

enum TestPhaseSum{
  TP_Null;
  
  TP_Tick(info:String);

  TP_StartTestCase(test_case_data:TestCaseData);
  TP_StartTest(method_call:MethodCall);

  TP_ReportFatal(err:Error<TestFailure>);

  TP_Setup(f:TestFailure);
  TP_Before(f:TestFailure);
  TP_After(f:TestFailure);
  TP_Teardown(f:TestFailure);
  TP_Failures(xs:Cluster<TestFailure>);
   
  TP_ReportFailure(assertion:Assertion,method_call:MethodCall);
  TP_ReportTestComplete(method_call:MethodCall);
  TP_ReportTestCaseComplete(test_case_data:TestCaseData);

  TP_ReportTestSuiteComplete(test_suite:TestSuite);
}