package Package::Transporter::Generator::Universal::Automatic_Require;
use strict;
use warnings;
use Scalar::Util qw();
use parent qw(
	Package::Transporter::Generator
);
our $VERBOSE = 1;
my $used = 0;

sub ATB_PKG() { 0 };
sub ATB_PKG_PATTERNS() { 1 };

sub _init {
	my ($self) = (shift);

	$self->[ATB_PKG_PATTERNS] //= ['::'];
#	map(s/::$/(\$|::)/, @{$self->[ATB_PKG_PATTERNS]});
	return;
}

sub implement {
	my ($self, $pkg, $pkg_name, $sub_name) = (shift, shift, shift, shift);

	my $found = 0;
	foreach my $pattern (@{$self->[ATB_PKG_PATTERNS]}) {
		if(substr($pattern, -2) eq '::') {
			my $l = length($pattern) -2;
			next unless(substr($pkg_name, 0, $l) eq 
				substr($pattern, 0, $l));
		} else {
			next unless($pkg_name eq $pattern);
		}
		$found = 1;
		last;
	}

	unless($found) {
		return($self->failure(undef, $sub_name, "::Automatic_Require []"));
	}

	my $sub_text = sprintf(q{
my $self = shift(@_);
require %s;
return(\&%s::%s);
},
		$pkg_name,
		$pkg_name, $sub_name);
	return($pkg->transport(\$sub_text, $self));

#	return($_[0]->failure(undef, $_[2], '::Automatic_Require [implement not available]'));
}

1;

