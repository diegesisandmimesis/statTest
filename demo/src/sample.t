#charset "us-ascii"
//
// sample.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// Non-interative test of the statTest module.  Runs a couple tests, including
// some that should fail.
//
// It can be compiled via the included makefile with
//
//	# t3make -f makefile.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

// Abstract number-picking class we'll use as a mixin for our tests below.
class PickANumber: object
	// These are the outcomes 
	outcomes = List.generate({i: i}, 10)

	// Run a single trial:  pick a number between 1 and 10
	pickOutcome() { return(rand(10) + 1); }
;

// Same as above, but with an off-by-one error.
class PickANumberFailed: PickANumber
	// Run a single trial:  pick a number between 0 and 9
	pickOutcome() { return(rand(10)); }
;

// RMS test that should succeed
class RMSTestGood: PickANumber, StatTestRMS;
// RMS test that should fail
class RMSTestBad: PickANumberFailed, StatTestRMS;

// Pair of fencepost tests, as above
class FencepostTestGood: PickANumber, StatTestFencepost;
class FencepostTestBad: PickANumberFailed, StatTestFencepost;

class ChiTestGood: PickANumber, StatTestChiSquare;
// Off-by-one errors are usually only caught by chi square with much
// larger sample sizes, so we skew the results even more to guarantee
// a failure.
class ChiTestBad: PickANumberFailed, StatTestChiSquare
	pickOutcome() { return(rand(5)); }
;

class RunsTestGood: PickANumber, StatTestRuns;
class RunsTestBad: PickANumberFailed, StatTestRuns
	_index = 0
	pickOutcome() {
		_index += 1;
		_index = (_index % outcomes.length) + 1;
		return(outcomes[_index]);
	}
;

versionInfo: GameID;
gameMain: GameMainDef
	_goodTests = static [
		RMSTestGood,
		FencepostTestGood,
		ChiTestGood,
		RunsTestGood
	]
	_badTests = static [
		RMSTestBad,
		FencepostTestBad,
		ChiTestBad,
		RunsTestBad
	]
	newGame() {
		local t;

		"These tests should succeed (producing no output):\n ";
		_goodTests.forEach(function(cls) {
			"<.p> ";
			t = cls.createInstance();
			"<<t.svc>>:\n ";
			t.runTest();
			t.report();
		});

		"<.p>These tests should fail (and generate errors):\n ";
		_badTests.forEach(function(cls) {
			"<.p> ";
			t = cls.createInstance();
			"<<t.svc>>:\n ";
			t.runTest();
			t.report();
		});
	}
;
