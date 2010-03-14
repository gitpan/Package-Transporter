#!/usr/bin/perl -W -T
use strict;

package Synopsis;
use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_potential('::Export', 'FOR_BRANCH', ['hello_world', 'yn']);
};

sub hello_world() { print "Hello World.\n"; };
sub yn($) { print STDERR ($_[0] ? 'Yes' : 'No'), "\n"; };


package Synopsis::Ex1;
use Package::Transporter sub{eval shift};

yn(!defined(&hello_world));
yn(potentially_defined('hello_world'));

hello_world();

yn(defined(&hello_world));
exit(0);