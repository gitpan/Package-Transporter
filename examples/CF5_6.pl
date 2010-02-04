package CF5;
use strict;
use Package::Transporter sub{eval shift};

BEGIN {
	my $pkg = Package::Transporter->new();
	$pkg->global_constants('IS_', 'YES' => 1, 'NO' => 0);
}

package CF6;
use Package::Transporter sub{eval shift};

die() if (IS_YES == IS_NO);