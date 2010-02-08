package CF5;
use strict;
use Package::Transporter sub{eval shift};

BEGIN {
	my $pkg = Package::Transporter->new();
	$pkg->package_constants('IS_', 'TRUE' => 1, 'FALSE' => 0);
}

package CF6;
use Package::Transporter sub{eval shift}, 'mix_in:CF5';

die() if (IS_TRUE == IS_FALSE);
