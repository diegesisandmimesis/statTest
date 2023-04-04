#charset "us-ascii"
//
// runsTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// Non-interactive test of the root mean square test.
//
// It can be compiled via the included makefile with
//
//	# t3make -f runsTest.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

// Test equivalent to flipping a coin.
class DemoTest: StatTestRuns
	outcomes = static [ 0, 1 ]
	// Run a single trial:  flip a coin.
	pickOutcome() { return(rand(2)); }
;
versionInfo: GameID;
gameMain: GameMainDef
	newGame() {
		local t;

		// Create the new test object.
		t = new DemoTest();

		// Run the tests.
		t.runTest();

		// Report the results.
		t.report();
	}
;
