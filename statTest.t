#charset "us-ascii"
//
// statTest.t
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

	startTimestamp() { _testTimestamp = new Date(); }
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
