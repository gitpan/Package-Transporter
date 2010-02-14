package CF3;
use strict;

use Package::Transporter sub{eval shift}, sub {
	$_[0]->array_indices('ATB_', [], qw(NAME  TYPE  STOCK  PRICE));
};

#...
sub sell {
	my ($self, $amount) = @_;

	$self->[ATB_STOCK] -= $amount;
	my $costs = $amount * $self->[ATB_PRICH];

	return($costs);
}
