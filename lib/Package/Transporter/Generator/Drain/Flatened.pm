package Package::Transporter::Generator::Drain::Flatened;
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
	for (my $i = 0; $i < $#{$self->[ATB_DATA]}; $i += 2) {
		my ($name, $value) = ($self->[ATB_DATA][$i],
			$self->[ATB_DATA][$i+1]);
		$value =~ s,\},\\},sg;
		push(@values, ["$prefix$name", $value]);
	}
	return(\@values);
}

1;