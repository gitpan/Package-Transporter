package Package::Transporter::Symbol::Package_Constants;
use strict;
use warnings;
use Package::Transporter sub{eval shift};
use Package::Transporter::Package sub{eval shift};
use Package::Transporter::Symbol;

# This module implements a convenience function, which implements the
# generated symbols as constant functions.

sub package_constants {
	my ($self, $prefix) = (shift, shift);

	my $properties = Package::Transporter::binary_properties(1,
		[16, 32, 64, 128, 256],
		[SCP_PUBLIC, MIX_IMPLICIT]);

	my $symbols = $self->named_values($prefix, undef, @_);
	$self->application('constant_function', $properties, @$symbols);

	return($symbols);
}


1;
