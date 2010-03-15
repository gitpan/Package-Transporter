package CF4;
use strict;

use Package::Transporter sub{eval shift}, sub {
        $_[0]->register_drain('::Random', 'FOR_SELF', 'ATB_',
		qw(NAME  TYPE  STOCK  PRICE));
};

#...
sub sell {
	my ($self, $amount) = @_;

	$self->{+ATB_STOCK} -= $amount;
	my $costs = $amount * $self->{+ATB_PRICE};

	return($costs);
}