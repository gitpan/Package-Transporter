package Package::Transporter::Generator::Constant_Function::Enumerated;
use strict;
use warnings;
use parent qw(
	Package::Transporter::Generator::Constant_Function
	Package::Transporter::Generator
);

sub ATB_DATA() { 1 };

sub determine {
	my ($self, $prefix) = @_;

	my @values = ();
	my $i = 0;
	foreach my $name (@{$self->[ATB_DATA]}) {
		push(@values, ["$prefix$name", $i++]);
	}
	return(\@values);
}

1;
