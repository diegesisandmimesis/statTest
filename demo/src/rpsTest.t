#charset "us-ascii"
//
// rpsTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// Non-interactive test of the root mean square test.
//
// It can be compiled via the included makefile with
//
//	# t3make -f rpsTest.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

// A naive engine for playing rock paper scissors.
rockPaperScissors: object
	// Our method for selecting a random number.  This version
	// works;  to illustrate how the fenceposting logic can catch
	// off-by-one errors, change this to be just "return(rand(3))".
	//randomNumber() { return(rand(3) + 1); }

	// This is a plausible-looking off-by-one error.
	randomNumber() { return(rand(3)); }

	// We can't call this method "throw", because that's a reserved word.
	shoot() {
		local r;

		switch(randomNumber) {
			case 1:
				r = 'rock';
				break;
			case 2:
				r = 'paper';
				break;
			case 3:
				r = 'scissors';
				break;
		}

		return(r);
	}
;

// Test the rock paper scissors "logic" defined above.
class RPSTest: StatTestFencepost
	// These are the outcomes 
	outcomes = static [ 'rock', 'paper', 'scissors' ]

	// Invoke the rock paper scissors selection logic once.
	pickOutcome() { return(rockPaperScissors.shoot()); }
;
versionInfo: GameID;
gameMain: GameMainDef
	newGame() {
		local t;

		t = new RPSTest();
		t.runTest();
		t.report();
	}
;
