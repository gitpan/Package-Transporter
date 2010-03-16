#!/usr/bin/perl -W -T
use strict;
use lib '.'; # allows the .pl files to be read via require()

package eponymous_directory;
# eponymous means the same name ... as the package 'eponymous_directory'

use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_potential('::Eponymous_Directory', 'FOR_SELF', undef);
};

yn(potentially_defined('hello_worlds'));
yn(potentially_defined('hello_world'));
yn(defined(&hello_world));

hello_world();

yn(defined(&hello_world));

exit(0);