#!/usr/bin/perl -W -T
use strict;
use Data::Dumper;

use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_universal('::Re_Blessed', 'URI');
};

my $uri1 = URI->potentially_new('//www.perl.org');
my $uri2 = $uri1;
print STDERR Dumper($uri1, $uri2);

$uri1->scheme('http');
print STDERR Dumper($uri1, $uri2);

exit(0);
