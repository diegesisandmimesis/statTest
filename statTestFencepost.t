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
// you'd get some values you weren't expecting (all the 0s) and you would
// never get some results you were expecting (any 10s).
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

	// This will be a vector containing our counts.
	_bucket = nil

	// The number of buckets.
	_bucketLen = nil

	runTest() {
		local i, idx;

		initTest();

		// We add an extra bucket before and after the "real"
		// buckets, to hold the out of range low and out of range high
		// values, respectively.
		_bucketLen = outcomes.length + 2;

		// Initialize the buckets.
		_bucket = new Vector(_bucketLen);
		_bucket.fillValue(0, 1, _bucketLen);

		// Run the tests.
		for(i = 0; i < iterations; i++) {
			// Figure out which bucket this result goes in.
			if((idx = outcomes.indexOf(pickOutcome())) == nil)
				idx = 0;

			// Add one to the index.  This is because we added
			// an out of range low bucket to the start of the
			// list.
			idx += 1;

			// Sanity check the index to make sure we've got
			// a bucket for it.
			// Anything one or lower is out of range low.
			if(idx < 1)
				idx = 1;
			// Anything that goes in the last bucket (or tries
			// to go higher) is out of range high.
			if(idx > _bucketLen)
				idx = _bucketLen;

			// Add the value to the bucket.
			_bucket[idx] += 1;
		}
	}

	// Output the report.
	report() {
		local err, i;

		// We have zero errors so far.
		err = 0;

		// Bucket 1 is for out of range low values, so if it isn't
		// empty, that's a bug.
		if(_bucket[1] != 0) {
			err += 1;
			_error('ERROR:  <<toString(_bucket[1])>>
				outcomes under value');
		}

		// The last bucket is for out of range high, so if it isn't
		// empty, that's a bug too.
		if(_bucket[_bucketLen] != 0) {
			err += 1;
			_error('ERROR:  <<toString(_bucket[_bucketLen])>>
				outcomes over value');
		}

		// The other buckets are the "real" values, so if any of
		// them ARE empty, that's a bug.
		for(i = 2; i < _bucketLen; i++) {
			if(_bucket[i] != 0) continue;
			err += 1;
			_error('ERROR:  bucket <<toString(i - 1)>>
				(<<toString(outcomes[i - 1])>>)
				empty');
		}

		// Now see how many errors we ran into.
		if(err == 0)
			_debug('passed');
		else
			_error('FAILED');
	}
;
