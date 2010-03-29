package Package::Transporter::Generator::Drain::Flatened;
use strict;
use warnings;
use Carp qw();
use parent qw(
	Package::Transporter::Generator::Drain::Constant_Function
	Package::Transporter::Generator
);

sub ATB_DATA() { 1 };

sub determine {
	my ($self, $prefix, $data) = @_;

	my @values = ();
	my %seen = ();
	for (my $i = 0; $i < $#$data; $i += 2) {
		my ($name, $value) = ($data->[$i], $data->[$i+1]);
		if(exists($seen{$name})) {
			next if($seen{$name} eq $value);
			Carp::confess("Conflicting values for name '$name'");
		}
		$seen{$name} = $value;
		$value =~ s,\},\\},sg;
		push(@values, ["$prefix$name", $value]);
	}
	return(\@values);
}

1;
