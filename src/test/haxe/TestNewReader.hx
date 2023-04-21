package;

import stx.testtest.Tests;
import stx.test.Test;

using stx.Nano;
using stx.Log;
using stx.Parse;
using eu.ohmrun.Pml;
import stx.test.module.Auto;

class TestNewReader{
  static public function main(){
    final logger     = __.logger().global();
          
    final v       = __.resource('tests').string();
    trace(v);
    final vI      = __.pml().parseI()(v.reader()).toChunk();
    for(x in vI){
      final r       = Auto.reply();
      trace(r);
      $type(r);
    }
  }
}