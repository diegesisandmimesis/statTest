#charset "us-ascii"
//
// statTest.t
//
// This is a TADS3 module for implementing simple statistical tests.
//
// Each type of test is an abstract class.  To use them, you should
// define a derived class containing additional properties of methods,
// and then instance your custom class to run the tests.
//
// Most of the classes just need (listed below with the general format
// required):
//
//	outcomes = static []		The outcomes property should be
//					a List containing the allowed
//					result values for any given trial.
//
//	pickOutcome() {			The pickOutcome() method should
//		return(value);		run one trial and return a value,
//	}				where the value should be an element
//					of the options array defined above.
//
// Example:
//
// If the thing you want to test is the ability of rand() to pick a number
// between one and ten, you could do something like:
//
//	class DemoTest: StatTestRMS
//		outcomes = static [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
//		pickOutcome() { return(rand(10) + 1); }
//	;
//
// ...or equivalently....
//
//	class DemoTest: StatTestRMS
//		outcomes = perInstance(List.generate({i : i}, 10))
//		pickOutcome() { return(rand(10) + 1); }
//	;
//
// Here the List.generate() bit is just the native TADS3 way to populate
// a list with all the numbers from 1 to 10, useful if you need to test
// something with a wide range of possible values.
//
// The base class we used here is StatTestRMS, which will compute the normalized
// room mean square error of multiple (by default 10k) trials.  That's just an
// example.  There are several other test classes you use, explained further
// below.
//
// Once we've defined a class, we can then run the test via something like:
//
//	local t = new DemoTest();
//	t.runTest();			// actually runs the test
//	t.report();			// outputs the test-specific report(s)
//
//
// The supplied test classes are:
//
//	StatTestChiSquare		does a chi square goodness of fit test
//
//	StatTestFencepost		does a couple fenceposting/off-by-one
//					error checks
//
//	StatTestRMS			does a normalized root mean square
//					error test
//
//	StatTestRuns			does the Wald-Wolfowitz runs test
//
// There's a separate demo for each of these classes in the ./demo/ directory.
// In addition, the demo in ./demo/src/sample.t includes examples of tests
// implemented using each of these classes, both for tests that should
// succeed as well as tests that should fail (to demonstrate error
// handling).
//
// The base test class also implements a simple timestamp mechanism to
// measure elapsed time during tests.  This isn't used in any of the demo
// examples, but can be used to implement basic performance testing.
//
#include <adv3.h>
#include <en_us.h>

#include <bignum.h>
#include <date.h>

// Module ID for the library
statTestModuleID: ModuleID {
        name = 'Statistical Testing Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

// Base object class for everything in the module.
// We just use this as a way to get our logging methods on everything
// that needs them.
class StatTestObject: object
	// The svc property is a tag that will be added to all the
	// debugging and error output from instances of the class.
	svc = nil

	// Used by startTimestamp() and getInterval() below.
	_testTimestamp = nil

	// Record a timestamp, for use below.
	startTimestamp() { _testTimestamp = new Date(); }

	// Returns a BigNumber containing the length of time since
	// startTimestamp() was called, in seconds.
	getInterval() { return((_testTimestamp != nil)
		? ((new Date() - _testTimestamp) * 86400)
		: nil); }

	// Debugging and error logging methods.
	// The debug() method is a stub, overridden in stateTestDebug.t if
	// the __DEBUG_STAT_TEST flag is set at compile time.
	_debug(msg?) {}
	_error(msg?) { aioSay('\n<<(svc ? '<<svc>>: ' : '')>><<msg>>\n '); }
;

// Base class for all the tests.
class StatTest: StatTestObject
	svc = 'StatTest'

	// The number of individual trials to run.  In general, this is
	// the number of times pickOutcome() will be called.
	iterations = 10000

	// A List containing the allowed values returns by pickOutcome().
	outcomes = static []

	// Called at the start of runTest() to do any pre-test initialization.
	initTest() {}

	// Returns a the outcome of a single test.  E.g., a single roll of
	// the dice, picking a single random number, whatever.
	// Needs to be overwritten by derived classes or instances.
	pickOutcome() {}

	// Main test method.  Here we just have a stub method;  each of the
	// defined stat test classes implements its own version.  In general
	// you shouldn't have to write your own;  you probably only need
	// to touch pickOutcome() and maybe initTest().
	runTest() {}

	// Output the results.  Another stub method overwritten by each of
	// the stat test classes.  You shouldn't have to write your own,
	// but the code where you run the tests needs to explicitly call
	// this on any tests you've run (if you want to get any output).
	report() {}
;
