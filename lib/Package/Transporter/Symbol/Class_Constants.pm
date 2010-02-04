package Package::Transporter::Symbol::Class_Constants;
use strict;
use warnings;
use Package::Transporter sub{eval shift};
use Package::Transporter::Package sub{eval shift};
use Package::Transporter::Symbol;


# This module implements a convenience function, which implements the
# generated symbols as constant functions.

sub class_constants {
	my ($self, $prefix, $default) = (shift, shift, shift);

	unshift(@$default, SCP_PUBLIC, MIX_IMPLICIT);
	my $properties = Package::Transporter::binary_properties(1,
		[16, 32, 64, 128, 256], $default);

	my $symbols = $self->named_values($prefix, undef, @_);
	$self->application('constant_function', $properties, @$symbols);

	return($symbols);
}


1;