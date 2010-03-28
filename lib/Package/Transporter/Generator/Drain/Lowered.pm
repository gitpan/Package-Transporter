package Package::Transporter::Generator::Drain::Lowered;
use strict;
use warnings;
use parent qw(
	Package::Transporter::Generator::Drain::Constant_Function
	Package::Transporter::Generator
);

sub ATB_DATA() { 1 };

sub determine {
	my ($self, $prefix) = @_;

	my @values = ();
	foreach my $name (@{$self->[ATB_DATA]}) {
		my $value = "$prefix$name";
		push(@values, [$value, lc($value)]);
	}
	return(\@values);
}

1;