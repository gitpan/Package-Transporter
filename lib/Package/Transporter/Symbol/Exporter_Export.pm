package Package::Transporter::Symbol::Exporter_Export;
use strict;
use warnings;
use Package::Transporter sub{eval shift};
use Package::Transporter::Package sub{eval shift};
use Package::Transporter::Symbol;

# This module implements a convenience function, which implements the
# generated symbols as constant functions.

warn('This is unfinished work.'); #FIXME: completely untested
sub exporter_export {
	my ($self, $prefix, $default) = (shift, shift, shift);

	my $symbols = $self->from_variable('@EXPORT');
	$self->application('symbol_table', $properties, @$symbols);

	return($symbols);
}


1;