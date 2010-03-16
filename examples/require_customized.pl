#!/usr/bin/perl -W
use strict;
use lib '.'; # allows the .pl files to be read via require()

use Package::Transporter sub{eval shift}, sub {
	my $generator = $_[0]->create_generator('::Require_Customized',
		'GREET_TO' => 'Mundo');
	$_[0]->register_potential($generator, 'FOR_ANY', 'require_customized');
};

# This is not taint-safe!
require_customized('hello_world.pl');

exit(0);
