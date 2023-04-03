#charset "us-ascii"
//
// statTestRuns.t
//
#include <adv3.h>
#include <en_us.h>

#include <bignum.h>

// Wald-Wolfowitz runs test.
class StatTestRuns: StatTest
	svc = 'StatTestRuns'

	_nUp = nil		// number of times value went up
	_nDown = nil		// number of times the value went down
	_n = nil		// total number of runs
	_ev = nil		// computed expectation value
	_variance = nil		// computed variance
	_value = nil		// computed value

	// Critical value.  Here it's just a magic number, but it's
	// the upper/lower tail critical value for p=0.975/0.025 in
	// a standard normal distribution.  We take the absolute
	// value of the test statistic, so we only care about the
	// absolute value of the critical number.
	_critical = perInstance(new BigNumber(1.96))

	runTest() {
		local dir, i, lastDir, lastVal, v;

		// Initialize counters
		_nUp = 0;
		_nDown = 0;
		_n = 0;

		// We're running a total number of tests equal
		// to interations.  Here we one-off save the first
		// run to lastVal, because we only care about whether
		// the value goes up or down.
		lastVal = pickOutcome();

		// This is not a typo.  We want to run (iterations) tests,
		// but we already did one above, so we don't want to do
		// for(i = 0; i < iterations; i++) like we would otherwise.
		for(i = 1; i < iterations; i++) {
			v = pickOutcome();

			// Figure out if the value went up or down.
			if((dir = ((v >= lastVal) ? 1 : -1)) > 0)
				_nUp += 1;
			else
				_nDown += 1;

			// Figure out if we're still going the same
			// direction as the last choice.  If we are, then
			// we have a run.
			if((lastDir != nil) && (lastDir != dir))
				_n += 1;

			// Remember the current value and direction for
			// the next time through the loop.
			lastDir = dir;
			lastVal = v;
		}

	}

	report() {
		local z;

		if((z = value()) == 0) {
			_error('ERROR:  failed to compute Z value');
			return;
		}
		_debug('Z = <<toString(z.roundToDecimal(3))>>');
		_debug('mean = <<toString(mean().roundToDecimal(3))>>');
		_debug('variance = <<toString(variance().roundToDecimal(3))>>');
		if(z < critical())
			_debug('passed');
		else
			_error('FAILED');
	}

	// Get the computed value for our data that we'll compare against
	// the critical value.
	value() {
		if(_value != nil) return(_value);
		return(_value = ((new BigNumber(_n) - mean()) / variance())
			.getAbs());
	}

	// Compute the mean.
	// This and the computation for the variance are just straight
	// out of Wald-Wolfowitz.
	mean() {
		if(_ev != nil) return(_ev);
		if(_n == 0) return(0);
		return(_ev = (new BigNumber(2) * new BigNumber(_nUp)
			* new BigNumber(_nDown)
			/ new BigNumber(_n)) + new BigNumber(1));
	}

	// Compute the variance.
	variance() {
		local ev;

		if(_variance != nil)
			return(_variance);
		if((ev = mean()) == 0) return(0);
		return(_variance = ((ev - new BigNumber(1))
			* (ev - new BigNumber(2)))
			/ (new BigNumber(_n) - new BigNumber(1)));
	}

	critical() { return(_critical); }
;
