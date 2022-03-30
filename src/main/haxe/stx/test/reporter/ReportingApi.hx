package stx.test.reporter;

interface ReportingApi{
  public var green_tick(get,null):String;
  private function get_green_tick():String;

  public var green_tick_on_black(get,null):String;
  private function get_green_tick_on_black():String;

  public var red_cross(get,null):String;
  private function get_red_cross():String;

  public var red_cross_on_black(get,null):String;
  private function get_red_cross_on_black():String;

  public var yellow_question_on_black(get,null):String;
  private function get_yellow_question_on_black():String;

  public var bad(get,null):String;
  private function get_bad():String;
  
  public var good(get,null):String;
  private function get_good():String;

  public function println(str:String,indent:String = ""):Void;
  public function print_status(icon:String,str:String,indent:String = ""):Void;

  public function method_call_string(test:MethodCall):String;
  public function test_case_string(test_case:TestCaseData):String;

  public function warn_string(string:String):String;
  public function ok_string(string:String):String;
  public function fail_string(string:String):String;
  public function info_string(string:String):String;
}