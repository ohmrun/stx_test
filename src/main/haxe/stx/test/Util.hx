package stx.test;

class Util{
  static public inline function or_res<U>(fn:Void->U,?pos:Pos):Res<U,TestFailure>{
    return try{
      __.accept(fn());
    }catch(e:ErrorDef<Dynamic>){
      __.reject(e.map(E_Test_Err));
    }catch(e:Dynamic){
      throw e;
      __.reject(__.fault(pos).of(E_Test_Dynamic(e)));
    }
    //return __.accept(fn());
  }
}