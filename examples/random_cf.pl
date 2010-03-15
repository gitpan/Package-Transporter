#!/usr/bin/perl -W -T
use strict;

package Parent_Class;
use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_drain('::Random', 'FOR_FAMILY',
		'ATB_', qw(NAME  STOCK  PRICE));
};

package Child_Class;
BEGIN {our @ISA = ('Parent_Class')}; # more like 'use parent ...'
use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_drain('::Random', 'FOR_SELF',
		'ATB_', qw(SALE));
};

print STDOUT 'ATB_PRICE=', ATB_PRICE, "\n";
print STDOUT 'ATB_SALE=', ATB_SALE, "\n";
exit(0);
