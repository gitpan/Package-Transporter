#!/usr/bin/perl -W -T
use strict;

package Synopsis;
use Package::Transporter sub{eval shift}, sub {
	my $generator = $_[0]->create_generator('::Export', 
		'POSIX', 'Data::Dumper');
	$_[0]->register_potential($generator, 'FOR_SELF');
};

sub yn($) { print STDERR ($_[0] ? 'Yes' : 'No'), "\n"; };

yn(!defined(&O_EXCL));
yn(potentially_defined('O_EXCL'));

print STDERR O_EXCL(), "\n"; # now points to POSIX::O_EXCL()
print Dumper(\@ARGV);

yn(defined(&O_EXCL));
exit(0);
