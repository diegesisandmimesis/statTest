#charset "us-ascii"
//
// statTestChiSquare.t
//
#include <adv3.h>
#include <en_us.h>

#include <bignum.h>

// Do a chi square goodness of fit test.
class StatTestChiSquare: StatTest
	svc = 'StatTestChiSquare'

	// Property that will hold the chi square widget.
	_chiSquareTest = nil

	runTest() {
		local i;

		initTest();

		// Most of the chi square logic lives in its own class,
		// in statTestChiSquareTest.t.
		_chiSquareTest = new StatTestChiSquareTest(outcomes.length);

		// Add however many trials we've been asked to run.
		for(i = 0; i < iterations; i++) {
			_chiSquareTest.addValue(
				outcomes.indexOf(pickOutcome()));
		}
	}

	// Output the results.
	report() {
		local v;

		v = _chiSquareTest.chiSquare();

		_debug('iterations = <<toString(iterations)>>');
		_debug('chi square = <<toString(v.roundToDecimal(3))>>');
		_debug('critical = <<_chiSquareTest.checkCritical(v)>>');

		if(_chiSquareTest._success)
			_debug('success');
		else
			_error('FAILED');
	}
;
