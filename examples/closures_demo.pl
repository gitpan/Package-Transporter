#!/usr/bin/perl -W -T
use strict;

use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_potential('::Closures_Demo', 'FOR_ANY', 'calc_(\d+)');
};

sub calc {
	my ($correction, $a, $b) = @_;
	return($a * $correction/100 + $b);
};

package Other;
use Package::Transporter sub{eval shift};

print calc_5(7, 8), "\n"; # sets $correction = 5
#my $result = calc_5 7, 8; # error

exit(0);
