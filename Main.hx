import stx.Test;
import stx.unit.Test;

class Main {
	static function main() {
		var test 	= new TestTest();
		var results = new Runner().apply(
			[new DependsTest()]
		).handle(
			(arr) -> {
				new Reporter().report(arr);
				//trace("DONE");
				// for(x in arr){
				// 	for(y in x){
				// 		trace(y);
				// 	}
				// };
			}
		);
	}
}
