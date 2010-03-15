package CF3;
use strict;

use Package::Transporter sub{eval shift}, sub {
        $_[0]->register_drain('::Enumerated', 'FOR_SELF', 'ATB_',
        	qw(NAME  SALE  STOCK  PRICE));
};

#...
sub sell {
	my ($self, $amount) = @_;

#	return if (ATB_SALE == IS_FALSE);
	$self->[ATB_STOCK] -= $amount;
	my $costs = $amount * $self->[ATB_PRICH];

	return($costs);
}