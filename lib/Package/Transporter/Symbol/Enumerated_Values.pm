package Package::Transporter::Symbol::Enumerated_Values;
use strict;
use warnings;
use Package::Transporter::Package sub{eval shift};
use Package::Transporter::Symbol;


sub enumerated_values {
	my ($self, $prefix, $default, $start) = (shift, shift, shift, shift);

	my $properties = Package::Transporter::binary_properties(1, [2, 4, 8], $default);

	unless (defined($start)) {
		my $count = $self->symbols->lookup_prefixed($prefix);
		$start = $#$count+1;
	};

	my @symbols = ();
	foreach my $argument (@_) {
		my $name = "$prefix$argument";
		push(@symbols, Package::Transporter::Symbol->new($name, $start++, $properties));
	}

	$self->symbols->remove($prefix);
	push(@symbols, Package::Transporter::Symbol->new($prefix, $start));

	$self->symbols->add(\@symbols);

	return(\@symbols);
}


1;