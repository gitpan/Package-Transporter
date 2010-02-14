package Package::Transporter::Symbol::Enumerated_Values;
use strict;
use warnings;
use Package::Transporter::Package sub{eval shift};
use Package::Transporter::Symbol;


sub enumerated_values {
	my ($self, $prefix, $default, $iterator) = (shift, shift, shift, shift);

	unless(defined($iterator)) {
		my $count = 0;
		$iterator = sub { my $rv = $count; $count += 1; return($rv); };
	}
	my $properties = Package::Transporter::binary_properties(1,
		[2, 4, 8], $default);

	my @symbols = ();
	my $value;
	foreach my $argument (@_) {
		my $name = "$prefix$argument";
		$value = $iterator->();
		push(@symbols, Package::Transporter::Symbol->new($name, $value, $properties));
	}

#	$self->symbols->remove($prefix);
#	push(@symbols, Package::Transporter::Symbol->new($prefix, $value));

	$self->symbols->add(\@symbols);

	return(\@symbols);
}


1;
