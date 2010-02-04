package Package::Transporter::Application;
use strict;
use warnings;
use Carp qw();

use Package::Transporter sub{eval shift};

sub ATB_NAME() { 0 };
sub ATB_PROPERTIES() { 1 };
sub ATB_ARGUMENTS() { 2 };
sub ATB_DATA() { 3 };

my @EXPORT = qw(ATB_NAME ATB_PROPERTIES ATB_ARGUMENTS ATB_DATA);
sub import { # forward to Package::Transporter::_import_subroutines
	return(Package::Transporter::_import_subroutines((caller())[0], \@EXPORT, @_));
}

our $AUTOLOAD;
sub AUTOLOAD { # forward to Package::Transporter::_AUTOLOAD
	Package::Transporter::_AUTOLOAD(sub{eval shift}, __PACKAGE__, 'Application',
		$AUTOLOAD, @_)
}

my $PROPERTY_RANGE = [16, 32, 64, 128, 256];

sub new {
	my ($class, $name, $properties) = (shift, shift, shift);

	if (ref($properties) eq 'ARRAY') {
		$properties = Package::Transporter::binary_properties(1,
			$PROPERTY_RANGE, $properties);
	}
	my @arguments = @_;

	my $data = undef;
	if ($name =~ m,^(.*?):(.*)$,) {
		($name, $data) = ($1, $2);
	}
	my $self = [$name, $properties, \@arguments, $data];
	bless($self, $class);
	Internals::SvREADONLY(@{$self}, 1);

	return($self);
}


sub clone {
        my ($self) = (shift);

        my $clone = [@$self];
        bless($clone, __PACKAGE__);

        return($clone);
}


sub set_properties {
	$_[0][ATB_PROPERTIES] = (ref($_[1]) eq 'ARRAY')
		? Package::Transporter::binary_properties($_[0][ATB_PROPERTIES],
			$PROPERTY_RANGE, $_[1])
		: $_[1];
}


sub has_properties {
	my ($self, $properties) = (shift);

	foreach my $property (@$properties) {
	        if (($self->[ATB_PROPERTIES] & $property) != $property) {
			return(0);
		}
	}
	return(1);
}


sub is_instant_implementation {
	return(($_[0][ATB_PROPERTIES] & IMP_INSTANT) == 0);
}

sub is_on_demand_implementation { 
	return(($_[0][ATB_PROPERTIES] & IMP_ON_DEMAND) > 1);
}

sub is_private_scope {
	return(($_[0][ATB_PROPERTIES] & SCP_PRIVATE) == 0);
}

sub is_public_scope {
	return(($_[0][ATB_PROPERTIES] & SCP_PUBLIC) > 1);
}

sub is_explicit_mix {
	return(($_[0][ATB_PROPERTIES] & MIX_EXPLICIT) == 0);
}

sub is_implicit_mix {
	return(($_[0][ATB_PROPERTIES] & MIX_IMPLICIT) > 1);
}

sub is_never_undo {
	return(($_[0][ATB_PROPERTIES] & UND_NEVER) == 0);
}

sub is_triggered_undo {
	return(($_[0][ATB_PROPERTIES] & UND_TRIGGERED) > 1);
}

sub is_local_propagation {
	return(($_[0][ATB_PROPERTIES] & PRP_LOCAL) == 0);
}

sub is_universal_propagation {
	return(($_[0][ATB_PROPERTIES] & PRP_UNIVERSAL) > 1);
}


sub selected_symbols {
	my ($self, $symbols) = @_;

	my @selected = ();
	foreach my $symbol (@{$self->[ATB_ARGUMENTS]}) {
		if (length(ref($symbol))) { # probably Package::Transporter::Symbol
			push(@selected, $symbol);
		} elsif (substr($symbol, -1, 1) eq '_') {
			push(@selected, 
				@{$symbols->lookup_prefixed($symbol)});
		} else {
			push(@selected, $symbols->lookup_name($symbol));
		}
	}

	return(\@selected);
}


sub apply {
	my ($self) = (shift);

 	my $method = $self->[ATB_NAME];
	if ($method =~ m,\W,) {
		Carp::confess("Illegal name '$method'.");
	}

	my $selected = $self->selected_symbols(@_);
	my @transaction = $self->$method($selected);
	unless (defined($transaction[1])) {
		if ($self->is_triggered_undo()) {
			Carp::confess("Ooops, method '$method' does not support undo.");
		}
		$transaction[1] = \q{};
	}
	return(@transaction);
}


sub DESTROY { }; # can't autoload

1;