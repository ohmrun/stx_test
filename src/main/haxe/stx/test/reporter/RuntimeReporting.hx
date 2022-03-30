package stx.test.reporter;

class RuntimeReporting implements ReportingApi extends Clazz{
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
  public function println(str:String,indent:String = ""):Void{
    final v = '${indent}${str}';
    Console.log(v);
  }
  public function print_status(icon:String,str:String,indent:String = ""):Void{
    final v = '$icon ${indent}${str}';
    Console.log(v);
  }
  public function method_call_string(test:MethodCall){
    return '<blue>${test.class_name}::${test.field_name}</blue>';
  }
  public function test_case_string(test_case:TestCaseData){
    return '<light_white>${test_case.class_name}</light_white>';
  }
  public function warn_string(string:String):String{
    return '<yellow>$string</yellow>';
  }
  public function ok_string(string:String):String{
    return '<green>$string</green>';
  }
  public function fail_string(string:String):String{
    return '<red>$string</red>';
  }
  public function info_string(string:String):String{
    return '<blue>$string</blue>';
  }
}