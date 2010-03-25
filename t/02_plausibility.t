#!/usr/bin/perl -W -T
use strict;
use Test::Simple tests => 10;

local($@);
eval qq{hello_world();};
ok($@ !~ m/Package::Transporter/, 'T000: Not us, yet.');

package Basic_Test1;
use Test::Simple;
use Package::Transporter sub{eval shift}, sub {
	ok(ref($_[0]) eq 'Package::Transporter::Standard',
		'T001: Convenience object of right type.');
	ok($_[0]->name eq 'Basic_Test1',
		'T002: Correct name.');
	ok(ref($_[0]->search) eq 'Package::Transporter::Path_Partition',
		'T003: Search object of right type.');
};
local($@);
eval qq{hello_world();};
ok($@ =~ m/Package::Transporter/, 'T004: It\'s us who complains.');

package Basic_Test2;
use Test::Simple;

local($@);
eval q{Package::Transporter->import(sub{eval shift}, []);};
ok($@, 'T005: 2nd argument must be code reference.');

package Basic_Test3;
use Test::Simple;
use Package::Transporter;

my $a = time;
{
	my $pkg = Package::Transporter->new(sub{eval shift});
	my $code = 'return($a)';
	my $b = $pkg->transport(\$code);
	ok($a = $b, 'T006: Access lexical via new');
	local($@);
	eval q{$pkg->transport($code);};
	ok($@, 'T007: Normal scalar for transport is error.');
}

my $found = Package::Transporter::find_generator(['FOR_ANY']);
ok(!defined($found), 'T008: Impossible ISA value');

use Package::Transporter::Rule::Standard;
my $rule = Package::Transporter::Rule::Standard->new(sub{}, '', '');
ok(ref($rule) eq 'Package::Transporter::Rule::Standard',
	'T009: Package::Transporter::Rule::Standard works.');

exit(0);
