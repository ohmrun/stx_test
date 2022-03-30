package stx.test.reporter;

class MacroReporting implements ReportingApi extends Clazz{
  public var green_tick(get,null):String;
  private function get_green_tick():String{
    return '✓';
  }
  public var green_tick_on_black(get,null):String;
  private function get_green_tick_on_black():String{
    return '$green_tick';
  }
  public var red_cross(get,null):String;
  private function get_red_cross():String{
    return '✗';
  }
  public var red_cross_on_black(get,null):String;
  private function get_red_cross_on_black():String{
    return '$red_cross';
  }
  public var yellow_question_on_black(get,null):String;
  private function get_yellow_question_on_black():String{
    return '?';
  }
  public var bad(get,null):String;
  private function get_bad():String{
    return red_cross_on_black;
  }
  public var good(get,null):String;
  private function get_good():String{
    return green_tick_on_black;
  }
  public function println(str:String,indent:String = ""):Void{
    final v = '${indent}${str}';
    std.Sys.println(v);
  }
  public function print_status(icon:String,str:String,indent:String = ""):Void{
    final v = '$icon ${indent}${str}';
    std.Sys.println(v);
  }
  public function method_call_string(test:MethodCall){
    return '${test.class_name}::${test.field_name}';
  }
  public function test_case_string(test_case:TestCaseData){
    return '${test_case.class_name}';
  }
  public function warn_string(string:String):String{
    return '$string';
  }
  public function ok_string(string:String):String{
    return '$string';
  }
  public function fail_string(string:String):String{
    return '$string';
  }
  public function info_string(string:String):String{
    return '$string';
  }
}