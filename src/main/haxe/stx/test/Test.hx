package stx.test;

using stx.Nano;

using stx.Test;

import stx.test.test.*;

using stx.test.Logging;

class Test {
	static function main() {
		#if stx.boot
			boot();
		#else
			var logger : stx.log.logger.Unit = __.log().global;
			#if (sys)
					logger = new stx.log.logger.ConsoleLogger();
				stx.log.Signal.instance.attach(logger);
			#end
			logger.includes.push("**/*");
			//logger.includes.push("stx/stream");
			logger.level = TRACE;

			__.log().info('main');

			var signal = new Runner().apply(
				[
					new MacroTestCaseLiftTest(),
					new DependsTest(),
					new stx.test.test.TestTest(),
					new UseAsyncTest(),
					new SynchronousErrorTest(),
					new AsyncResultTest(),
				]
			);
			new Reporter(signal).enact();
		#end
	}
	static public function tests(){
		return [
			new MacroTestCaseLiftTest(),
			new DependsTest(),
			new TestTest(),
			new UseAsyncTest(),
			new SynchronousErrorTest(),
			new AsyncResultTest(),
			new TestResource()
		];
	}
}