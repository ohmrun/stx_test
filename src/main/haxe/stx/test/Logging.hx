package stx.test;

using stx.Nano;
using stx.Log;
using stx.Pkg;

class Logging{
  static public function log(wildcard:Wildcard){
    //trace(__.pkg().toString());
    return stx.Log.pkg(__.pkg());
  }
}