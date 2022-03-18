package stx.test;

import haxe.rtti.Meta;

class MacroTestCaseLift{
  static public function get_tests<T:TestCase>(self:T,timeout){
    final clazz           = std.Type.getClass(self);
    final type_meta       = Meta.getType(clazz);
    final all_test_async  = Reflect.hasField(type_meta,"stx.test.async");
    final field_meta      = Meta.getFields(clazz); 

    // final fields        = std.Type.getInstanceFields(clazz).map_filter(
    //   (string:String) -> (string:Chars).starts_with("test").if_else(
    //     () -> {
    //       final meta      = (field_meta:haxe.DynamicAccess<Dynamic>).get(string);
    //       final is_async  = Reflect.hasField(meta,"stx.test.async");
    //       return __.option({ :string);
    //     },
    //     () -> None
    //   )
    // );
    
  }
}
