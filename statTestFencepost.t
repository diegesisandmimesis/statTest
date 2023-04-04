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

	// The bucket to hold generic mismatches.
	_errorBucket = nil

	useRange = nil
	_minValue = nil
	_maxValue = nil

	runTest() {
		local i, idx, v;

		initTest();

		if(useRange == true) {
			_minValue = outcomes.minVal();
			_maxValue = outcomes.maxVal();
		}

		// We add one extra bucket before and two extra buckts after
		// the "real" buckets.  The "before" bucket is to hold out of
		// range low results and the "after" buckets are to hold
		// generic unmatched results and out of range high results,
		// respectively.
		_bucketLen = outcomes.length + 3;

		// The index for the catchall error bucket.  The out of range
		// low bucket is always index 1 and the out of range high
		// bucket index is always the length of the array, so this
		// is the only one that requires math.  We just save the
		// value to make it easier to refer to later.
		_errorBucket = _bucketLen - 1;

		// Initialize the buckets.
		_bucket = new Vector(_bucketLen);
		_bucket.fillValue(0, 1, _bucketLen);

		// Run the tests.
		for(i = 0; i < iterations; i++) {
			// Get the outcome of a single trial.
			v = pickOutcome();

			// Figure out which bucket this result goes in.
			// If we get a match, we use it, done.  If we
			// don't get a match, we have some decisions to make.
			if((idx = outcomes.indexOf(v)) == nil) {
				// We didn't get a match, so we check to
				// see if we've been told to use ranges.
				// If we have, we check the value against
				// the min and max values, and put the result
				// in the out of range low or out of range
				// high bucket if either applies, and fall
				// back on the catchall error bucket otherwise.
				if(useRange == true) {
					if(v < _minValue)
						idx = 1;
					else if(v > _maxValue)
						idx = _bucketLen;
					else
						idx = _errorBucket;
				} else {
					// We're not using ranges, so
					// we punt.
					idx = _errorBucket;
				}
			} else {
				// Add one to the index.  This is because we
				// added an out of range low bucket to the
				// start of the list.
				idx += 1;
			}

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
				of <<toString(iterations)>>
				outcomes under value');
		}

		// The last bucket is for out of range high, so if it isn't
		// empty, that's a bug too.
		if(_bucket[_bucketLen] != 0) {
			err += 1;
			_error('ERROR:  <<toString(_bucket[_bucketLen])>>
				of <<toString(iterations)>>
				outcomes over value');
		}

		// The error bucket is for general mismatches, and is generally
		// where things end up if we're not doing range checks.
		// Its index is always _bucketLen - 1, but we have a property
		// to refer to it.
		if(_bucket[_errorBucket] != 0) {
			err += 1;
			_error('ERROR:  <<toString(_bucket[_errorBucket])>>
				of <<toString(iterations)>>
				outcome values unmatched');
		}

		// The other buckets are the "real" values, so if any of
		// them ARE empty, that's a bug.
		for(i = 2; i < _errorBucket; i++) {
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
