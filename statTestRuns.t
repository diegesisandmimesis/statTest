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

	iterations = 10000

	_n1 = nil		// number of times value went up
	_n2 = nil		// number of times the value went down
	_n = nil		// sum of _n1 and _n2
	_R = nil		// total number of runs
	_mean = nil		// computed mean
	_variance = nil		// computed variance
	_value = nil		// computed value

	// Critical value.  Here it's just a magic number, but it's
	// the upper/lower tail critical value for p=0.975/0.025 in
	// a standard normal distribution.  We take the absolute
	// value of the test statistic, so we only care about the
	// absolute value of the critical number.
	_critical = perInstance(new BigNumber(1.96))

	// Here we map whatever values we get into a coin toss, and then
	// keep track of how many heads and tails come up, as well as the
	// total number of "runs".
	runTest() {
		local i, l, lastVal, v;

		initTest();

		// Initialize counters
		_n1 = 0;
		_n2 = 0;
		_R = 0;

		// Pre-compute the magic value that turns a "heads" into
		// a "tails".
		l = outcomes.length / 2;

		lastVal = nil;

		for(i = 0; i < iterations; i++) {
			// Get the index of a single result in the
			// outcomes list.
			if((v = outcomes.indexOf(pickOutcome())) == nil)
				continue;

			// Check to see if the index of the current result
			// is in the first or second half of the outcomes
			// array.  We're basically just turning a pick a
			// number between one and n choice into a coin toss.
			if(v <= l) {
				_n1 += 1;		// count this result
				v = 0;
			} else {
				_n2 += 1;		// count this result
				v = 1;
			}

			// If the value of the "coin toss" isn't the same as
			// it was before, we've got the start of a new "run".
			if(v != lastVal)
				_R += 1;

			// Remember the current "coin toss" for the next
			// iteration.
			lastVal = v;
		}

		// Convert our counters to bignums.  Entirely to make it
		// easier for the computational methods that come later.
		_R = new BigNumber(_R);
		_n1 = new BigNumber(_n1);
		_n2 = new BigNumber(_n2);
		_n = _n1 + _n2;
	}

	// Report the results.
	report() {
		local z;

		// Number of "heads"
		_debug('n1 = <<toString(_n1)>>');

		// Number of "tails"
		_debug('n2 = <<toString(_n2)>>');

		// Number of runs.
		_debug('R = <<toString(_R)>>');

		// Computed values.
		_debug('mean = <<toString(mean().roundToDecimal(3))>>');
		_debug('variance = <<toString(variance().roundToDecimal(3))>>');

		// Get the Wald-Wolfowitz value.
		if((z = value()) == nil) {
			_error('ERROR:  failed to compute Z value');
			return;
		}
		_debug('Z = <<toString(z.roundToDecimal(3))>>');

		// See if we pass.
		if(z < critical())
			_debug('passed');
		else
			_error('FAILED');
	}

	// Compute the mean.
	// This and the computation for the variance are just straight
	// out of Wald-Wolfowitz.
	mean() {
		if(_mean != nil) return(_mean);
		if(_R == 0) return(new BigNumber(0));
		return(_mean = ((new BigNumber(2) * _n1 * _n2) / _n)
			+ new BigNumber(1));
	}

	// Compute the variance.
	variance() {
		local ev;

		if((ev = mean()) == 0) return(new BigNumber(0));
		if(_n < 2) return(new BigNumber(0));
		return(_variance =
			((ev - new BigNumber(1)) * (ev - new BigNumber(2)))
				/ (_n - new BigNumber(1)));
	}

	// Get the computed value for our data that we'll compare against
	// the critical value.
	value() {
		local v;

		if(_value != nil) return(_value);
		v = variance();
		if(v == 0) return(nil);

		// We computed the variance, but we need the standard
		// deviation now.
		v = v.sqrt();
		//_debug('sigma = <<toString(v)>>');

		return(_value = ((_R - mean()) / v).getAbs());
	}

	critical() { return(_critical); }
;
