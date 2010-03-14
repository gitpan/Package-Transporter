#!/usr/bin/perl -W -T
use strict;
use Carp qw();
use DBI;
use Package::Transporter sub{eval shift};
use Package::Transporter::Generator::SQL_Table;
warn('See the manual page Package::Transporter::Generator::SQL_Table');


my $dbh = DBI->connect('DBI:mysql:perlsub', *LOGIN*, *PASSWORD*) ||
	Carp::confess("connect: $DBI::errstr\n");

# another lexical variable visible to hello_world()
my $date = scalar(localtime(time()));

{
	my $pkg = Package::Transporter->new(sub{eval shift});
	my $generator = Package::Transporter::Generator::SQL_Table->new($pkg, $dbh);
	$generator->prototypes();
	$pkg->register_potential($generator, 'FOR_SELF');
};

yn(potentially_defined('hello_worlds'));
yn(potentially_defined('hello_world'));
yn(defined(&hello_world));
#hello_world(7); also try this to see $date
hello_world();
yn(defined(&hello_world));
exit(0);