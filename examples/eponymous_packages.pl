#!/usr/bin/perl -W -T
use strict;

# eponymous means the same package name ... look for "main.pm"
use lib 'eponymous_packages';
unless (-d 'eponymous_packages') {
	print STDERR "Script can only be run from the examples directory or wherever the directory 'eponymous_packages' is.\n";
}

use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_potential('::Eponymous_Packages', 'FOR_SELF', '');
};

yn(potentially_defined('hello_worlds')); # Ooops!
yn(potentially_defined('hello_world'));
yn(!defined(&hello_world));

hello_world();

yn(defined(&hello_world));

exit(0);
