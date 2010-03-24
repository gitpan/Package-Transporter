#!/usr/bin/perl -W -T
use strict;

use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_drain('::Flatened', 'FOR_ANY', 'IS_',
		TRUE => 1, FALSE => 0);
	my $yn = q{
 		return(q{print STDOUT ($_[0] ? 'Yes' : 'No'), "\n";});
	};
	$_[0]->register_potential($yn, 'FOR_ANY', 'yn');
};

print STDOUT ((IS_TRUE == 1) ? 'Ok' : 'Disorder'), "\n";

package Synopsis;
use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_drain('::Enumerated', 'FOR_SELF', 'ATB_',
		qw(HELLO  WORLD));
	$_[0]->register_potential('::Export', 'FOR_BRANCH', ['hello_world']);
	$_[0]->register_potential('::Hello_Anything', 'FOR_SELF', 'salut_');
};

print "ATB_WORLD: ", ATB_WORLD, "\n";
sub hello_world { print "Hello World.\n"; }

package Synopsis::Desc1;
use Package::Transporter sub{eval shift};

yn(!defined(&hello_world));
yn(potentially_defined('hello_world'));

print STDOUT ((IS_TRUE == 1) ? 'Ok' : 'Disorder'), "\n";
hello_world(); # first rule

yn(defined(&hello_world));

package sisponyS::Desc2;
BEGIN {our @ISA = ('Synopsis')}; # to be correct
use Package::Transporter sub{eval shift};

my $obj = bless( \(my $o = 0), 'sisponyS::Desc2');

yn(!potentially_defined('hello_world'));
yn(!defined(&salut_monde));
yn(!potentially_defined('salut_monde'));
yn($obj->potentially_can('salut_monde')); # no autovivification
yn($obj->can('salut_monde')); # with autovivification

$obj->salut_monde(); # second rule

yn(!defined(&sisponyS::Desc2::salut_monde));
yn(!defined(&Synopsis::Desc1::salut_monde));
yn(defined(&Synopsis::salut_monde));

exit(0);
