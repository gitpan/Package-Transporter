package Package::Transporter::Symbol::Lower_Case_Values;
use strict;
use warnings;
use Package::Transporter::Package sub{eval shift};
use Package::Transporter::Symbol;


sub lower_case_values {
	my ($self, $prefix, $default) = (shift, shift, shift);

	my $properties = Package::Transporter::binary_properties(1,
		[2, 4, 8], $default);

	my @symbols = ();
	foreach my $argument (@_) {
		my $value = lc($argument);
		my $name = "$prefix$argument";
		push(@symbols, Package::Transporter::Symbol->new($name, $value, $properties));
	}
	$self->symbols->add(\@symbols);

	return(\@symbols);
}


1;