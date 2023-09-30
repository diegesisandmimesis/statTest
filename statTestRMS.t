#charset "us-ascii"
//
// statTestRMS.t
//
#include <adv3.h>
#include <en_us.h>

#include <bignum.h>

// Normalized root mean square test.
class StatTestRMS: StatTest
	svc = 'StatTestRMS'

	// Will hold a vector of the counts for each outcome.
	results = nil

	// Will hold the average count.
	mean = nil

	// Will hold the normalized RMS error
	rms = nil

	// Magic number we compare the normalized RMS error to
	_criticalValue = 0.05

	construct(opts?, ev?, i?) {
		if(i != nil) iterations = i;
		if(opts != nil) outcomes = opts;
		if(ev != nil) mean = ev;
	}

	// Compute the expected mean.
	getMean() {
		if(mean != nil) {
			if(!mean.ofKind(BigNumber))
				mean = new BigNumber(mean);
			return(mean);
		}

		if((outcomes == nil) || (outcomes.length < 1)) return(0);
		mean = new BigNumber(1.0) / new BigNumber(outcomes.length);

		return(mean);
	}

	runTest() {
		local i, idx;

		initTest();

		// Create and initialize the results vector.
		results = new Vector(outcomes.length);
		results.fillValue(0, 1, outcomes.length);

		// Run the tests.
		for(i = 0; i < iterations; i++) {
			if((idx = outcomes.indexOf(pickOutcome())) != nil)
				results[idx] += 1;
		}

		// Compute the RMS error.
		rms = getNormalizedRMS();
	}

	report() {
		if(rms == nil) {
			_error('ERROR:  failed to compute rms');
			return;
		}

		_debug('normalized RMS error =
			<<toString(rms.roundToDecimal(3))>>');

		// Just a heuristic.  We compute the normalized RMS and
		// just compare it to a magic number.
		if(rms < _criticalValue)
			_debug('passed');
		else
			_error('FAILED');
	}

	// Compute the normalized RMS error.
	getNormalizedRMS() {
		local err, i, m, t;

		// Sanity check ourselves.
		if((results == nil) || (results.length < 1))
			return(nil);

		// Compute the expected mean count for each result.
		m = getMean();

		// The actual computation.

		// The number of trials we ran.
		t = new BigNumber(iterations);

		// Initialize the error term to zero.
		err = new BigNumber(0.0);

		// Go through our result counts.
		for(i = 1; i <= results.length; i++) {
			// The right side is the difference between the
			// observed average and the computed "ideal" average,
			// squared.
			// We add this to the cumulative error.
			err += (m - (new BigNumber(results[i]) / t))
				.raiseToPower(2);
		}

		// Divide the error by the number of results.
		err /= new BigNumber(results.length);

		// Take the square root.
		err = err.sqrt();

		// And divide by the mean.
		err /= m;

		// Return what we came up with.
		return(err);
	}
;
