#charset "us-ascii"
//
// statTestChiSquare.t
//
#include <adv3.h>
#include <en_us.h>

#include <bignum.h>

class StatTestChiSquare: StatTest
	svc = 'StatTestChiSquare'

	_chiSquareTest = nil

	runTest() {
		local i;

		_chiSquareTest = new StatTestChiSquareTest(outcomes.length);
		for(i = 0; i < iterations; i++) {
			_chiSquareTest.addValue(
				outcomes.indexOf(pickOutcome()));
		}
	}

	report() {
		local v;

		v = _chiSquareTest.chiSquare();

		_debug('iterations = <<toString(iterations)>>');
		_debug('chi square = <<toString(v)>>');
		_debug('critical = <<_chiSquareTest.checkCritical(v)>>');

		if(_chiSquareTest._success)
			_debug('success');
		else
			_error('FAILED');
	}
;
