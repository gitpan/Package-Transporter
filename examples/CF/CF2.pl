package CF2;
use strict;

use Package::Transporter sub{eval shift}, sub {
        $_[0]->register_drain('::Flatened', 'FOR_SELF', 'IS_',
		'ON_SALE' => 1);
};

my $apples = IS_ON_SALE;
my $oranges = 1;
