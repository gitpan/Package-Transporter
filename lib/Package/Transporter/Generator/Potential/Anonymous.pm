package Package::Transporter::Generator::Potential::Anonymous;
use strict;
use warnings;
use parent qw(
	Package::Transporter::Generator
);

sub implement {
	my $self = shift;
	return($self->[0]->(@_));
}

1;
