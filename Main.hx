
using stx.Nano;

import stx.Test;
import stx.unit.Test;

import stx.test.*;

using stx.test.Logging;

class Main {
	static function main() {
		var logger : stx.log.logger.Unit = stx.log.Facade.unit();
		#if (sys )
				logger = new stx.log.logger.ConsoleLogger();
			stx.log.Signal.instance.attach(logger);
		#end
		logger.includes.push("stx/test");
		logger.includes.push("stx/stream");
		logger.level = DEBUG;

		__.log().info('main');

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
