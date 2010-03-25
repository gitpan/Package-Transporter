#!/usr/bin/perl -W -T
use strict;

use Package::Transporter::Lite sub{eval shift}, sub {
#	$_[0]->register_drain('::Flatened', 'IS_',
#		TRUE => 1, FALSE => 0);
	my $yn = q{
 		return(q{print STDOUT ($_[0] ? 'Yes' : 'No'), "\n";});
	};
	$_[0]->register_potential($yn, 'yn');
	$_[0]->register_potential('::Hello_Anything', 'hello_');
};

yn(!defined(&hello_world));

#print STDOUT ((IS_TRUE == 1) ? 'Ok' : 'Disorder'), "\n";
hello_world(); # first rule

yn(defined(&hello_world));

exit(0);
