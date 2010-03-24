package Package::Transporter::Rule::Standard;
use strict;
use warnings;
use Package::Transporter::Rule::Gone;

sub ATB_GENERATOR() { 0 };
sub ATB_PRE_SELECT() { 1 };
sub ATB_SUB_MATCH() { 2 };
sub ATB_ARGC_MATCH() { 3 };
sub ATB_ARGS_MATCH() { 4 };

sub new {
	my ($class, $generator, $pkg_name, $sub_name, $argc_match) =
		(shift, shift, shift, shift, shift);

	my $self = [
		$generator, [$pkg_name, $sub_name], undef, $argc_match, [@_]];
	bless($self, $class);

	my $match_ref = ref($sub_name);
	if ($match_ref eq '') {
		$self->[ATB_PRE_SELECT][1] = '';
		if ($sub_name =~ m/^([a-z0-9]*_)/i) {
			$self->[ATB_PRE_SELECT][1] = $1 || '';
		}
	} elsif ($match_ref eq 'CODE') {
		$self->[ATB_PRE_SELECT][1] = '';
	}

	$self->[ATB_SUB_MATCH] = $self->create_matcher($sub_name);

	Internals::SvREADONLY(@{$self}, 1);
	return($self);
}


sub pre_select {
	return(@{$_[0][ATB_PRE_SELECT]});
}

sub release { 
	Internals::SvREADONLY(@{$_[0]}, 0);
	@{$_[0]} = ();
	bless($_[0], 'Package::Transporter::Rule::Gone');
	Internals::SvREADONLY(@{$_[0]}, 1);
}

sub create_matcher {
	my ($self, $name) = (shift, shift);

	my $matcher;
	my $name_ref = ref($name);
	if ($name_ref eq 'ARRAY') {
		$matcher = sub { scalar(grep($_ eq $_[1], @$name)) > 0 };
	} elsif ($name_ref eq 'CODE') {
		$matcher = $name;
	} elsif (length($name) == 0) {
		$matcher = sub { 1 };
	} elsif ($name =~ m,[^\w\:],) {
		$matcher = sub { $_[1] =~ m,$name,o };
	} elsif (substr($name, -1, 1) eq '_') {
		my $l = length($name);
		$matcher = sub { ($name eq substr($_[1], 0, $l)) };
	} else {
		$matcher = sub { ($_[1] eq $name) };
	}

	return($matcher);
}


sub check {
	my ($self, $pkg_name, $sub_name) = (shift, shift, shift);

	return(undef) unless ($self->[ATB_SUB_MATCH]->($pkg_name, $sub_name, @_));

	if (defined($self->[ATB_ARGC_MATCH])
	and ($self->[ATB_ARGC_MATCH] != scalar(@_))) {
		return(undef);
	}

	my $args = $self->[ATB_ARGS_MATCH];
	return($self->[ATB_GENERATOR]) unless (scalar(@$args));
	foreach my $i (0 .. $#$args) {
		return(undef) unless (ref($_[$i]) eq $args->[$i]);
	}

	return($self->[ATB_GENERATOR]);
}


1;
