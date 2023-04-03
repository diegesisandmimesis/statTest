#charset "us-ascii"
//
// statTestFencepost.t
//
#include <adv3.h>
#include <en_us.h>

#include <bignum.h>

// Fencepost/off-by-one test.
// This is designed to catch situations in which some specific values out of
// an expected range of values are never generated.  An example of this would
// be if you were wanting to generate integers between 1 and 10 and used
// rand(10) to do so.  This will actually generate integers from 0 and 9, so
// you'd get some values you weren't expecting (the zeros) and you would
// never get some results you were expecting (the tens).
// Here we just generate a bunch of results, verifying that we get some of
// every value we are expecting and none of any value we aren't expecting.
// In theory we could catch this with statistical tests, but if we have
// a situation in which we have a large number of possible output values,
// the absence of a single specific value might not be statistically
// significant enough to cause the test to fail unless a very large number
// of trials is run.  And even if it is, merely knowing that the output
// histogram isn't flat doesn't immediately tell you that the cause of the
// problem is an off-by-one (or other missing value) problem.
class StatTestFencepost: StatTest
	svc = 'StatTestFencepost'

	_bucket = nil
	_bucketLen = nil

	runTest() {
		local i, idx;

		_bucketLen = outcomes.length + 2;
		_bucket = new Vector(_bucketLen);
		_bucket.fillValue(0, 1, _bucketLen);

		for(i = 0; i < iterations; i++) {
			if((idx = outcomes.indexOf(pickOutcome())) == nil)
				idx = 0;
			idx += 1;
			if(idx < 1) idx = 1;
			if(idx > _bucketLen) idx = _bucketLen;
			_bucket[idx] += 1;
		}
	}

	report() {
		local err, i;

		err = 0;
		if(_bucket[1] != 0) {
			err += 1;
			_error('ERROR:  <<toString(_bucket[1])>>
				outcomes under value');
		}
		if(_bucket[_bucketLen] != 0) {
			err += 1;
			_error('ERROR:  <<toString(_bucket[_bucketLen])>>
				outcomes over value');
		}
		for(i = 2; i < _bucketLen; i++) {
			if(_bucket[i] != 0) continue;
			err += 1;
			_error('ERROR:  bucket <<toString(_bucket[i - 1])>>
				empty');
		}
		if(err == 0)
			_debug('passed');
		else
			_error('FAILED');
	}
;
