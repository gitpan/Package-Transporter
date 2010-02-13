package Package::Transporter::Symbol::Named_Values;
use strict;
use warnings;
use Package::Transporter::Package sub{eval shift};
use Package::Transporter::Symbol;


sub named_values {
	my ($self, $prefix, $default) = (shift, shift, shift);

	my $properties = Package::Transporter::binary_properties(1,
		[2, 4, 8], $default);

	my @symbols = ();
	if (scalar(@_) % 2) {
		Carp::confess("Odd number of arguments.");
	}
	while ($#_ > -1) {
		my ($name, $value) = (shift, shift);
		push(@symbols, Package::Transporter::Symbol->new(
			"$prefix$name", $value, $properties));
	}
	$self->symbols->add(\@symbols);

	return(\@symbols);
}


1;