#!/usr/bin/perl -W -T
use strict;

package Parent_Class;
use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_drain('::Flatened', 'FOR_FAMILY', 'ATB_',
		HELLO1 => 17, WORLD1 => 18);
};

sub yn($) { print STDERR ($_[0] ? 'Yes' : 'No'), "\n"; };

yn(defined(&ATB_HELLO1));
yn(!potentially_defined('ATB_HELLO1'));

package Child_Class;
BEGIN {our @ISA = ('Parent_Class')}; # more like 'use parent ...'
use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_drain('::Flatened', 'FOR_SELF', 'ATB_',
		HELLO2 => 27, WORLD2 => 28);
};

sub yn($) { print STDERR ($_[0] ? 'Yes' : 'No'), "\n"; };

yn(defined(&ATB_HELLO1));
yn(!potentially_defined('ATB_HELLO1'));

print STDOUT 'Symbolic Attribute Names: ', ATB_HELLO1, ATB_WORLD2, "\n";

exit(0);
