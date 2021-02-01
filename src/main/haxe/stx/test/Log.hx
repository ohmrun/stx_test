package stx.test;

using stx.Nano;
using stx.Log;

class Log{
  static public function log(wildcard:Wildcard){
    return stx.Log.unit().tag('stx.test');
  }
}