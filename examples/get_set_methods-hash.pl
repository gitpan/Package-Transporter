#!/usr/bin/perl -W -T
use strict;

use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_drain('::Random', 'FOR_SELF', 'ATB_', qw(WORLD));
	$_[0]->register_potential('::Get_Set_Methods', 'FOR_ANY');
};

my $obj = bless( {}, 'main');
$obj->set_world(1);

use Data::Dumper;
print STDERR Dumper($obj);

exit(0);
