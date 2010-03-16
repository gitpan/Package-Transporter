#!/usr/bin/perl -W
use strict;
use Carp qw();
use Package::Transporter::Generator::Simple_Stubs;

# eponymous means the same name as the package file base name,
# which is 'main' in this case (no package name set)
unless (-f 'simple_stubs.txt') {
	print STDERR "Script can only be run from the examples directory or wherever the simple_stubs.txt file is.\n";
}

use Package::Transporter sub{eval shift}, sub {
	my $generator = $_[0]->create_generator('::Simple_Stubs',
		'simple_stubs.txt');
	$_[0]->register_potential($generator, 'FOR_SELF');
};

sub yn($) { print STDERR ($_[0] ? 'Yes' : 'No'), "\n"; };

yn(potentially_defined('hello_worlds'));
yn(potentially_defined('hello_world'));
yn(!defined(&hello_world));

hello_world();

yn(defined(&hello_world));
exit(0);
