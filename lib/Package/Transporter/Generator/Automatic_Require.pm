package Package::Transporter::Generator::Automatic_Require;
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

	Carp::confess("Can't use __PACKAGE__ twice.") if($used);
	*UNIVERSAL::AUTOLOAD = sub { universal_autoload($self, @_); };
	*UNIVERSAL::DESTROY = sub {};
	$used = 1;

	if(0) {
		*UNIVERSAL::AUTOLOAD = undef;
		*UNIVERSAL::DESTROY = undef;
	}

	return;
}

sub matcher {
	return(sub { 0 });
}

sub implement {
	return($_[0]->failure(undef, $_[2], '::Automatic_Use [implement not available]'));
}

our $AUTOLOAD;
sub universal_autoload {
	my $self = shift;

	unless($AUTOLOAD =~ m,^(.*)::(\w+)$,) {
		Carp::confess("Can't recognize '$AUTOLOAD'.");
	}
	my ($pkg_name, $sub_name) = ($1, $2);
	unless($pkg_name eq $_[0]) {
		Carp::confess("Hm, what is '$_[0]'.");
	}

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
	return($self->[ATB_PKG]->transport(\$sub_text, $self));
}

1;

