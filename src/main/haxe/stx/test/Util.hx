package stx.test;

class Util{
  static public inline function or_res<U>(fn:Void->U,?pos:Pos):Res<U,TestFailure>{
    return try{
      __.accept(fn());
    }catch(e:Error<Dynamic>){
      __.log().debug('$e');
      __.reject(e.except().errate(E_Test_Refuse));
    }catch(e:haxe.Exception){
      __.log().debug('$e');
      __.reject(Refuse.make(Some(EXTERNAL(E_Test_Exception(e))),None,pos));
    }
    //return __.accept(fn());
  }
}