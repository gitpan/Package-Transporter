package Package::Transporter::Generator::Drain::Random;
use strict;
use warnings;
use parent qw(
	Package::Transporter::Generator::Drain::Constant_Function
	Package::Transporter::Generator
);

sub ATB_DATA() { 1 };

my %VALUES = ('FFFFFFFF' => 1);

sub determine {
	my ($self, $prefix) = @_;

	my @values = ();
	my $value = 'FFFFFFFF';
	foreach my $name (@{$self->[ATB_DATA]}) {
                while($VALUES{$value}) {
                        $value = sprintf('%08x', int(rand(2**32-1)));
                }
                $VALUES{$value} = 1;

		push(@values, ["$prefix$name", $value]);
	}
	return(\@values);
}

1;