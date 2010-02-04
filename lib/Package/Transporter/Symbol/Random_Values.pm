package Package::Transporter::Symbol::Random_Values;
use strict;
use warnings;
use Package::Transporter::Package sub{eval shift};
use Package::Transporter::Symbol;

my %VALUES = ();

sub random_values {
	my ($self, $prefix, $default) = (shift, shift, shift);

	my $properties = Package::Transporter::binary_properties(1, [2, 4], $default);

	my @symbols = ();
	foreach my $argument (@_) {
		my $name = "$prefix$argument";
		my $value;
		while(1) {
			$value = sprintf('%08x', int(rand(2**32-1)));
			next if (exists($VALUES{$value}));
			last;
		}
		$VALUES{$value} = 1;
		push(@symbols, Package::Transporter::Symbol->new($name, $value, $properties));
	}
	$self->symbols->add(\@symbols);

	return(\@symbols);
}


1;