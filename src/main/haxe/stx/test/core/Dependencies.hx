package stx.test.core;

class Dependencies{
  var source : Array<MethodCall>;

  public function new(source){
    this.source = source;
  }
  public function reply(){
    var target = source.copy();
    
  }
  // public function sort(lhs:Array<MethodCall>,rhs:Array<MethodCall>){
  //   return (arr.length){
  //     case 2 : 
  //     case 1 : arr;
  //     case 0 : [];
  //   }
  // }
  private function center(arr){
    return Math.round(this.source.length / 2);
  }
}