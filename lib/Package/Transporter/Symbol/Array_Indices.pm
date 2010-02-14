package Package::Transporter::Symbol::Array_Indices;
use strict;
use warnings;
use Package::Transporter sub{eval shift};
use Package::Transporter::Package sub{eval shift};
use Package::Transporter::Symbol;

# This module implements a convenience function, which implements the
# generated symbols as constant functions.

sub array_indices {
	my ($self, $prefix, $default) = (shift, shift, shift);

	my $properties = Package::Transporter::binary_properties(1,
		[16, 32, 64, 128, 256], $default);

#	unshift(@$properties, SCP_PUBLIC, MIX_IMPLICIT); # for _base version

	my $count = $#{$self->symbols->lookup_prefixed($prefix)};
	my $iterator = sub { return($count += 1); };

	my $symbols = $self->enumerated_values($prefix, [], $iterator, @_);
	$self->application('constant_function', $properties, @$symbols);

	return($symbols);
}


1;
