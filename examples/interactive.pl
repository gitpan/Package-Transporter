#!/usr/bin/perl -W
use strict;

use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_potential('::Interactive', 'FOR_ANY');
};

sub hello_world() { print "Hello World.\n"; }
print STDOUT hallo_welt();

exit(0);
