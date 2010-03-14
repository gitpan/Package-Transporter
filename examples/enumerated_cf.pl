#!/usr/bin/perl -W -T
use strict;

use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_drain('::Flatened', 'FOR_ANY', 'IS_',
		TRUE => 1, FALSE => 0);
};

package Parent_Class;
use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_drain('::Enumerated', 'FOR_FAMILY', 'ATB_',
		qw(HELLO1  WORLD1));
};

sub yn($) { print STDERR ($_[0] ? 'Yes' : 'No'), "\n"; };

yn(defined(&ATB_HELLO1));
yn(!potentially_defined('ATB_HELLO1'));

package Child_Class;
BEGIN {our @ISA = ('Parent_Class')}; # more like 'use parent ...'
use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_drain('::Enumerated', 'FOR_SELF', 'ATB_',
		qw(HELLO2  WORLD2));
};

sub yn($) { print STDERR ($_[0] ? 'Yes' : 'No'), "\n"; };

yn(defined(&IS_TRUE));
yn(defined(&ATB_HELLO1));
yn(!potentially_defined('ATB_HELLO1'));

print STDOUT 'Symbolic Attribute Names: ', IS_TRUE, ATB_HELLO1, ATB_WORLD2, "\n";

exit(0);
