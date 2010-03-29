package Package::Transporter::Generator::Drain::Enumerated;
use strict;
use warnings;
use parent qw(
	Package::Transporter::Generator::Drain::Constant_Function
	Package::Transporter::Generator
);

sub ATB_DATA() { 1 };

sub determine {
	my ($self, $prefix, $data) = @_;

	my @values = ();
	my $i = 0;
#	my %seen = ();
	foreach my $name (@$data) {
#		next if(exists($seen{$name}));
#		$seen{$name} = 1;
		push(@values, ["$prefix$name", $i++]);
	}
	return(\@values);
}

1;
