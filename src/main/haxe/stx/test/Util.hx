package stx.test;

class Util{
  static public inline function or_res<U>(fn:Void->U,?pos:Pos):Res<U,TestFailure>{
    return try{
      __.accept(fn());
    }catch(e:Error<Dynamic>){
      trace(e.stack);
      __.reject(e.except().errate(E_Test_Rejection));
    }catch(e:haxe.Exception){
      trace(e.stack);
      __.reject(Rejection.make(Some(REJECT(E_Test_Exception(e))),None,pos));
    }
    //return __.accept(fn());
  }
}