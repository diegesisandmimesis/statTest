#charset "us-ascii"
//
// statTestRMS.t
//
#include <adv3.h>
#include <en_us.h>

#include <bignum.h>

class StatTestRMS: StatTest
	svc = 'StatTestRMS'

	results = nil
	mean = nil

	rms = nil

	construct(opts?, ev?, i?) {
		if(i != nil) iterations = i;
		if(opts != nil) outcomes = opts;
		if(ev != nil) mean = ev;
	}

	getMean() {
		if((outcomes == nil) || (outcomes.length < 1)) return(0);

		if(mean != nil) {
			if(!mean.ofKind(BigNumber))
				mean = new BigNumber(mean);
			return(mean);
		}
		mean = new BigNumber(1.0) / new BigNumber(outcomes.length);

		return(mean);
	}

	initTest() {}
	testResult() { return(nil); }

	runTest() {
		local i, idx;

		initTest();

		results = new Vector(outcomes.length);
		results.fillValue(0, 1, outcomes.length);

		for(i = 0; i < iterations; i++) {
			if((idx = outcomes.indexOf(pickOutcome())) != nil)
				results[idx] += 1;
		}
		rms = getNormalizedRMS();
	}

	report() {
		if(rms == nil) {
			_error('ERROR:  failed to compute rms');
			return;
		}
		_debug('normalized RMS error =
			<<toString(rms.roundToDecimal(3))>>');
		if(rms < 0.05)
			_debug('passed');
		else
			_error('FAILED');
	}

	getNormalizedRMS() {
		local err, i, m, t;

		if((outcomes == nil) || (outcomes.length < 1))
			return(nil);
		m = getMean();

		t = new BigNumber(iterations);
		err = new BigNumber(0.0);
		for(i = 1; i <= outcomes.length; i++) {
			err += (m - (new BigNumber(results[i]) / t))
				.raiseToPower(2);
		}
		err /= new BigNumber(outcomes.length);
		err = err.sqrt();
		err /= m;

		return(err);
	}
;
