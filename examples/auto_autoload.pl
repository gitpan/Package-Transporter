#!/usr/bin/perl -W
use strict;

# This exampel is non-functional
use Package::Transporter sub{eval shift}, sub {
	my $generator = $_[0]->create_generator('::Potential::Auto_Autoload', 'URI');
	$_[0]->register_potential($generator, 'FOR_ANY');
};

use URI;
my $uri = URI->new('http:://www.perl.org');

exit(0);
