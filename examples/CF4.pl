package CF4;
use strict;

use Package::Transporter sub{eval shift}, sub {
	$_[0]->random_values('ATB_', [], qw(NAME  TYPE  STOCK  PRICE));
	$_[0]->application('constant_function', [], 'ATB_');
};

#...
sub sell {
	my ($self, $amount) = @_;

	$self->{+ATB_STOCK} -= $amount;
	my $costs = $amount * $self->{+ATB_PRICE};

	return($costs);
}
