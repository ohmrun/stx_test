package stx.test.auto;

using eu.ohmrun.Pml;
class Errors{ 
  static public function e(x:Atom,?section){
    var str ='unsupported form ${__.show(x)}';
    if(section!=null){
      str = '$str in $section';
    }
    return str;
  }
  static public function eI(section,?explanation){
    return E_Test_ReaderFailure(__.option(explanation).defv('unsupported form'),section);
  }
}