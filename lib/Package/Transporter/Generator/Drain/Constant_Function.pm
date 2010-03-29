package Package::Transporter::Generator::Drain::Constant_Function;
use strict;
use warnings;

sub ATB_DATA() { 1 };

my $cf = q{sub %s() { q{%s} };};
sub implement {
	my ($self, $pkg, $pkg_name, $sub_name, $data) =
		(shift, shift, shift, shift, shift);

	my $values = $self->determine($sub_name, $data);
	my $sub_body = join("\n", map(sprintf($cf, @$_), @$values));
	return($sub_body);
}

sub get_data {
	return($_[0][ATB_DATA]);
}

sub configure {
	my ($self) = (shift);
	push(@{$self->[ATB_DATA]}, @_);
	return;
}

sub _init {
	$_[0][ATB_DATA] = []; # no autobugification
	return;
}

1;
