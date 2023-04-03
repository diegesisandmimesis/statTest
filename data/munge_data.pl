#!/usr/bin/perl -w
#
# Just a little perl script to munge the raw text tables (cut and pasted
# from NIST) into the format we need them for the T3 source files.
#
use strict;

&main();
exit(0);

sub main {
	my($line, @ar);

	while(<>) {
		chomp;
		s/^(\s+)//g;
		@ar = split(/\s+/);
		$ar[0] =~ s/\.//g;
		printf("\t\t[ %s, %s, %s, %s, %s ],\n",
			$ar[1], $ar[2], $ar[3], $ar[4], $ar[5]);
	}
}

