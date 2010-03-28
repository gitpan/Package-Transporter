package Package::Transporter::Lite;
use strict;
use warnings;
use Carp qw();
use parent qw(
	Package::Transporter::Package
);

sub ATB_PKG_NAME() { 0 };
sub ATB_VISIT_POINT() { 1 };
sub ATB_DRAIN() { 2 };
sub ATB_POTENTIAL() { 3 };

use Package::Transporter::Generator;

my $generator_class = 'Package::Transporter::Generator';
my $autoload = q{
	my $object = shift(@_);

	our $AUTOLOAD;
	sub AUTOLOAD {
		my $sub_ref = $object->autoload($AUTOLOAD, @_);
		goto &$sub_ref if (defined($sub_ref));
	}
};

sub new {
	my ($class, $pkg_name, $visit_point) = @_;

	my $self = [
		$pkg_name, 
		$visit_point,
		[],
		[]
	];
	bless($self, $class);

	$visit_point->($autoload, $self);

	Internals::SvREADONLY(@{$self}, 1);
	return($self);
}

sub register_potential {
	my ($self, $potential, $matcher) = @_;

	my $generator = $self->recognize($potential, '');
	if (defined($matcher)) {
		my $value = $matcher;
		my $type = ref($value);
		if($type eq 'CODE') {
		} elsif($type eq '') {
			if($matcher =~ m,\W,) {
				$matcher = sub { $_[1] =~ m,$value,o };
			} elsif(substr($matcher, -1, 1) eq '_') {
				my $l = length($value);
				$matcher = sub { ($value eq substr($_[1], 0, $l)) };
			} else {
				$matcher = sub { ($_[1] eq $value) ? 1 : 0 };
			}
		} elsif ($type eq 'ARRAY') {
			$matcher = sub { 
				scalar(grep($_ eq $_[1], @$value)) > 0 };
		} else {
			Carp::confess("Don't know how to handle matcher type '$type'.");
		}
	} else {
		if ($generator->can('matcher')) {
			$matcher = $generator->matcher();
		} else {
			Carp::confess("Argument '$matcher' doesn't look like a matcher.");
		}
	}

	push(@{$self->[ATB_POTENTIAL]}, [$matcher, $generator]);
	return;
}

sub register_drain {
	my ($self, $drain) = (shift, shift);

	my $generator = $self->recognize($drain, '::Constant_Function');
	push(@{$self->[ATB_DRAIN]}, $generator);

	return;
}

sub implement_drain {
	my ($self) = @_;

	my $pkg_name = $self->[ATB_PKG_NAME];
	foreach my $generator (@{$self->[ATB_DRAIN]}) {
		$generator->run($self, $pkg_name);
	}
	return;
}

sub autoload {
	my ($self, $sub_name) = (shift, shift);

	my $pkg_name = $self->[ATB_PKG_NAME];
	if (($sub_name =~ s,^(.*)::,,) and ($pkg_name ne $1)) {
		Carp::confess("Got a request to handle subroutine '$sub_name' for foreign package '$1' in package '$pkg_name'.");
	}
	return(undef) if ($sub_name eq 'DESTROY');

	my $generator;
	foreach my $rule (@{$self->[ATB_POTENTIAL]}) {
		next unless ($rule->[0]->($pkg_name, $sub_name, @_));
		$generator = $rule->[1];
		last;
	}

	unless (defined($generator)) {
		return($generator_class->failure(undef, $sub_name,
			'package object: no rule found'));
	}
	return($generator->run($self, $pkg_name, $sub_name, @_));
}

sub import($$$) {
	my ($class, $visit_point, $configure) = @_;

	my $pkg_name = (caller)[0];
	my $pkg = $class->new($pkg_name, $visit_point);

	$configure->($pkg);
	$pkg->implement_drain;
	return;
}

1;
