#!/usr/bin/perl -W -T
use strict;

package Parent_Class;
use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_drain('::Flatened', 'FOR_FAMILY', 'ATB_', 
		'NAME' => 'Apple',
		'STOCK' => 71,
		'PRICE' => 9.99);
};

package Child_Class;
BEGIN {our @ISA = ('Parent_Class')}; # more like 'use parent ...'
use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_drain('::Flatened', 'FOR_SELF',
		'ATB_', 'SALE' => 'yes');
};

print STDOUT 'ATB_PRICE=', ATB_PRICE, "\n";
print STDOUT 'ATB_SALE=', ATB_SALE, "\n";
exit(0);
