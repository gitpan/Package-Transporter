#!/usr/bin/perl -W -T
use strict;

use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_potential('::Set_Accessors_Demo', 'FOR_ANY', 'set_');
};

my $obj = bless( {}, 'main');
$obj->set_world(1);

use Data::Dumper;
print STDERR Dumper($obj);

exit(0);