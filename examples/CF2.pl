package CF2;

use Package::Transporter sub{eval shift}, sub {
	$_[0]->package_constants('IS_', 'ON_SALE' => 1);
};

my $apples = IS_ON_SALE;
my $oranges = 1;
