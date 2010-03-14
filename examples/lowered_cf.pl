#!/usr/bin/perl -W -T
use strict;

package Parent_Class;
use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_drain('::Lowered', 'FOR_FAMILY', 'ATB_',
		qw(HELLO1  WORLD1));
};

sub yn($) { print STDERR ($_[0] ? 'Yes' : 'No'), "\n"; };

yn(defined(&ATB_HELLO1));
yn(!potentially_defined('ATB_HELLO1'));

package Child_Class;
BEGIN {our @ISA = ('Parent_Class')}; # more like 'use parent ...'
use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_drain('::Lowered', 'FOR_SELF', 'ATB_',
		qw(HELLO2  WORLD2));
};

sub yn($) { print STDERR ($_[0] ? 'Yes' : 'No'), "\n"; };

yn(defined(&ATB_HELLO1));
yn(!potentially_defined('ATB_HELLO1'));

print STDOUT 'Symbolic Attribute Names: ', ATB_HELLO1, ATB_WORLD2, "\n";

exit(0);
