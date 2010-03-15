package Package::Transporter::Generator::Constant_Function;
use strict;
use warnings;

sub ATB_DATA() { 1 };

my $cf = q{sub %s() { q{%s} };};
sub implement {
	my ($self, $pkg, $sub_name) = (shift, shift, shift);

	my $values = $self->determine($sub_name);
	my $sub_body = join("\n", map(sprintf($cf, @$_), @$values));
	return($sub_body);
}

sub consume {
	my ($self) = (shift);
	push(@{$self->[ATB_DATA]}, map(@{$_->[ATB_DATA]}, @_));
	return;
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