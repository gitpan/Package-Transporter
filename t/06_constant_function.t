#!/usr/bin/perl -W -T
use strict;
use Test::Simple tests => 8;

package Parent_Class;
use Test::Simple;
use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_drain('::Enumerated', 'FOR_FAMILY', 'ATB1_',
		qw(FOO1  BAR1));
	$_[0]->register_drain('::Enumerated', 'FOR_BRANCH', 'ATB5_',
		 qw(FOO3  BAR4));
#	$_[0]->register_drain('::Random', 'FOR_BRANCH', 'ATB5_',
#		 qw(FOO3  BAR4));
	$_[0]->register_drain('::Random', 'FOR_SELF', 'ATB2_',
		qw(FOO1  BAR1));
	$_[0]->register_drain('::Lowered', 'FOR_SELF', 'ATB3_',
		qw(FOO1  BAR1));
	$_[0]->register_drain('::Flatened', 'FOR_SELF', 'ATB4_',
		FOO1 => 99, BAR1 => 723);
};

ok(ATB1_FOO1 == 0, 'T102: value ATB1_FOO1');
ok(length(ATB2_FOO1) == 8, 'T104: value ATB2_FOO1');
ok(ATB3_FOO1 eq 'atb3_foo1', 'T106: value ATB3_FOO1');
ok(ATB4_FOO1 == 99, 'T108: value ATB4_FOO1');

package Child_Class;
use Test::Simple;
BEGIN {our @ISA = ('Parent_Class')}; # more like 'use parent ...'
use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_drain('::Enumerated', 'FOR_SELF', 'ATB1_',
		qw(FOO2  BAR2));
};

ok(ATB1_BAR1 == 1, 'T110: value ATB1_BAR1');
ok(ATB1_BAR2 == 3, 'T112: value ATB1_BAR2');

package Parent_Class::Branch;
use Test::Simple;
use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_drain('::Enumerated', 'FOR_SELF', 'ATB1_',
		qw(FOO2  BAR2));
};

ok(ATB5_BAR4 == 1, 'T110: value ATB5_BAR4');
ok(ATB1_BAR2 == 1, 'T112: value ATB1_BAR2');

exit(0);
