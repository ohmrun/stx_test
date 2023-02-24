package;

using stx.Test;
using tink.CoreApi;
using stx.Nano;
using stx.Show;
using stx.Log;
using stx.Config;

import stx.testtest.Tests;
import stx.test.Test;

class ReaderTest{
  static public function main(){
    final log    = __.log().global;
          log.level = INFO;
          //log.includes.push('stx/parse');
          //log.includes.push('eu/ohmrun/pml');
          //log.includes.push('stx/test');
    stx.Test.test(__).auto();
  }
  
}