package Package::Transporter::Generator::Universal::Re_Blessed;
use strict;
use warnings;
use Data::Swap qw();
use parent qw(
	Package::Transporter::Generator
);

sub ATB_PKG() { 0 };

sub implement {
	my ($self, $pkg, $pkg_name, $sub_name) = (shift, shift, shift, shift);
	
	if($sub_name ne 'potentially_new') {
		die();
	}

	return($self->alias($pkg,
		'Package::Transporter::Generator::Universal::Re_Blessed::potentially_new',
		'potentially_new'));
}

sub potentially_new {
	my $self = [@_];
	bless($self, __PACKAGE__);
	Internals::SvREADONLY(@{$self}, 1);
	return($self);
}

our $AUTOLOAD;
sub AUTOLOAD {
	unless($AUTOLOAD =~ m,^(.*)::(\w+)$,) {
		Carp::confess("Can't recognize request for subroutine '$AUTOLOAD'.");
	}
	my ($pkg_name, $sub_name) = ($1, $2);

	my $self = $_[0];
	Internals::SvREADONLY(@{$self}, 0);
	my $class = shift(@$self);

	my $file_name = $class;
	$file_name =~ s,::,/,sg;
	$file_name .= '.pm';
	require $file_name;

	my @args = splice(@$self);
	my $new = $class->new(@args);
	Data::Swap::swap($self, $new);

	my $autoload = "$class\::$sub_name";
	goto &$autoload;
}

#sub can {
#}

1;
