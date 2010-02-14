package Package::Transporter::Symbol::Single_Bit_Masks;
use strict;
use warnings;
use Package::Transporter::Package sub{eval shift};
use Package::Transporter::Symbol;


sub single_bit_masks {
	my ($self, $prefix, $default) = (shift, shift, shift);

	my $properties = Package::Transporter::binary_properties(1,
		[16, 32, 64, 128, 256], $default);

	my $count = 2 ** scalar(@{$self->symbols->lookup_prefixed($prefix)});
	my $iterator = sub { my $rv = $count; $count *= 2; return($rv); };

	my $symbols = $self->enumerated_values($prefix, [], $iterator, @_);
	$self->application('constant_function', $properties, @$symbols);

	return($symbols);
}


1;
