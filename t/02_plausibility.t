#!/usr/bin/perl -W
use strict;
use Test::Simple tests => 12;

use Package::Transporter sub{eval shift}, sub {
	my $pkg = $_[0];
	$pkg->package_constants('IS_',
		'TRUE' => 1,
		'TRUE_MAYBE' => '\Hällo World$.\\',
		'FALSE' => 0,
		'UNDEFINED' => undef,
		);
 	$pkg->array_indices('ATB_', [], qw(NAME  TYPE  STOCK  PRICE));
 	$pkg->single_bit_masks('FLAG_', [], qw(MOVING  TURNING  LIGHTS));
};

ok((IS_TRUE eq '1'), 'Symbolic true.');
ok((IS_FALSE eq '0'), 'Symbolic false.');
ok((IS_TRUE_MAYBE eq '\Hällo World$.\\'), 'Non-Ascii and escape chars.');
ok((not defined(IS_UNDEFINED)), 'Symbolic undef.');
ok((ATB_NAME eq '0'), 'First enumerated attribute of 4.');
ok((ATB_PRICE eq '3'), 'Last enumerated attribute of 4.');
ok((FLAG_MOVING eq '1'), 'First bit mask of 3.');
ok((FLAG_LIGHTS eq '4'), 'Last bit mask of 3.');

my $pkg = Package::Transporter->new();
$pkg->assign('ATB_STOCK' => my $stock_index);
ok(($stock_index eq '2'), 'Assigned value.');
my $type_index = $pkg->retrieve('ATB_TYPE');
ok(($type_index eq '1'), 'Retrieved value.');

package Test_Mix_Main;
use Package::Transporter sub{eval shift}, 'mix_in:*';
use Test::Simple;

ok((IS_TRUE eq '1'), 'Symbolic true (mixed in from main).');
ok((IS_FALSE eq '0'), 'Symbolic false (mixed in from main).');


exit(0);
