import stx.Test;
import stx.unit.Test;

import stx.test.*;

class Main {
	static function main() {
		trace('main');
		#if (sys )
			stx.log.Signal.instance.attach(new stx.log.logger.ConsoleLogger());
		#end
		var signal = new Runner().apply(
			[
				new DependsTest(),
				new TestTest(),
				new UseAsyncTest(),
				new SynchronousErrorTest(),
				new AsyncResultTest(),
			]
		);
		new Reporter(signal).enact();
	}
}
