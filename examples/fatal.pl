#!/usr/bin/perl -W -T
use strict;
use Carp;

use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_potential('::Fatal', 'FOR_SELF', 'fatal_');
};

sub yn($) { print STDERR ($_[0] ? 'Yes' : 'No'), "\n"; };

yn(!defined(&fatal_open));
yn(potentially_defined('fatal_open'));

fatal_open(my $F, 'a');

yn(defined(&fatal_open));
exit(0);
