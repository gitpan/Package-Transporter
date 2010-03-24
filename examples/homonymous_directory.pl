#!/usr/bin/perl -W
use strict;
use lib '.'; # allows the .pl files to be read via require()

unless (-d 'homonymous_directory') {
	print STDERR "Script can only be run from the examples directory or wherever the 'homonymous_directory' is.\n";
}

package homonymous_directory;
# homonymous means the same name ... as the package 'homonymous_directory'

use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_potential('::Homonymous_Directory', 'FOR_SELF', undef);
};

yn(!potentially_defined('hello_worlds'));
yn(potentially_defined('hello_world'));
yn(!defined(&hello_world));

hello_world();

yn(defined(&hello_world));
exit(0);
