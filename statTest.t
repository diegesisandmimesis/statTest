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
//	options = static []		The options property should be
//					a List containing the allowed
//					outcomes for any given trial.
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
//		outcomes = List.generate({i : i}, 10)
//		pickOutcome() { return(rand(10) + 1); }
//	;
//
// Here the List.generate() bit is just the native TADS3 way to populate
// a list with all the numbers from 1 to 10.
//
// The base class we used is StatTestRMS, which will compute the normalized
// room mean square error of multiple (by default 10k) trials.
//
// We can then run the test via something like:
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

class StatTestObject: object
	svc = nil

	_testTimestamp = nil

	// Record a timestamp, for use below.
	startTimestamp() { _testTimestamp = new Date(); }

	// Returns a BigNumber containing the length of time since
	// startTimestamp() was called, in seconds.
	getInterval() { return((_testTimestamp != nil)
		? ((new Date() - _testTimestamp) * 86400)
		: nil); }

	_debug(msg?) {}
	_error(msg?) { aioSay('\n<<(svc ? '<<svc>>: ' : '')>><<msg>>\n '); }
;

class StatTest: StatTestObject
	svc = 'StatTest'

	iterations = 10000

	outcomes = static []

	// Called at the start of runTest() to do any pre-test initialization.
	initTest() {}

	// Returns a the outcome of a single test.  E.g., a single roll of
	// the dice, picking a single random number, whatever.
	pickOutcome() {}

	// Main test method, calls pickOutcome() multiple times (as specified
	// by interations).
	runTest() {}

	// Output the results.  Not called automatically.
	report() {}
;
