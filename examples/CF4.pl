package CF4;
use strict;

use Package::Transporter sub{eval shift};
BEGIN {
	my $pkg = Package::Transporter->new();
	$pkg->random_values('ATB_', [], qw(NAME  TYPE  STOCK  PRICE));
	$pkg->application('constant_function', [], 'ATB_');
}

#...
sub sell {
	my ($self, $amount) = @_;

	$self->{+ATB_STOCK} -= $amount;
	my $costs = $amount * $self->{+ATB_PRICE};

	return($costs);
}