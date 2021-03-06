package stx.test;

class Util{
  static public inline function or_res<U>(fn:Void->U,?pos:Pos):Res<U,TestFailure>{
    return try{
      __.accept(fn());
    }catch(e:Err<Dynamic>){
      __.reject(e.map(E_Test_Err));
    }catch(e:Dynamic){
      __.reject(__.fault(pos).of(E_Test_Dynamic(e)));
    }
  }
}