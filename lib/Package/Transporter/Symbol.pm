package Package::Transporter::Symbol;
use strict;
use warnings;

use Package::Transporter sub{eval shift};

sub ATB_ID() { 0 };
sub ATB_NAME() { 1 };
sub ATB_VALUE() { 2 };
sub ATB_PROPERTIES() { 3 };

my $PROPERTY_RANGE = [2, 4, 8];

my %IDS = ();
sub new {
	my ($class, $name, $value, $properties) = (shift, shift, shift, shift);

	if (ref($properties) eq 'ARRAY') {
		$properties = Package::Transporter::binary_properties(1,
			$PROPERTY_RANGE, $properties);
	}
	my $id;
	while(1) {
		$id = sprintf('%08x', int(rand(2**32-1)));
		next if (exists($IDS{$id}));
		last;
	}
	$IDS{$id} = 1;

	my $self = [$id, $name, $value, $properties || 1];
	bless($self, $class);
	Internals::SvREADONLY(@{$self}, 1);

	return($self);
}


sub set_name { 
	if (($_[0][ATB_PROPERTIES] & STG_COMPLETED) == 1) {
		Carp::confess("Symbol stage is completed - no further changes allowed.");
	}
	$_[0][ATB_NAME] = $_[1];
	return;
}


sub set_value {
	if (($_[0][ATB_PROPERTIES] & STG_COMPLETED) == 1) {
		Carp::confess("Symbol stage is completed - no further changes allowed.");
	}
	$_[0][ATB_VALUE] = $_[1]; 
	return;
}


sub set_properties {
	$_[0][ATB_PROPERTIES] = (ref($_[1]) eq 'ARRAY')
		? Package::Transporter::binary_properties($_[0][ATB_PROPERTIES],
			$PROPERTY_RANGE, $_[1])
		: $_[1];
}


sub binary_properties {
	my ($result, $range, $properties) = (shift, shift, shift);

PROP:	foreach my $property (@$properties) {
		my $value = ($property & 1);
		foreach my $position (@$range) {
			next unless ($property & $position);
			if ($value) {
				$result |= $position; 
			} else {
				$result &= ~ (2 ** $position);
			}
			next PROP;
		}
		Carp::confess("Could not find property '$_[1]'.");
	}
	return($result);
}


sub is_automatic_quoting { 
	return(($_[0][ATB_PROPERTIES] & QTG_AUTOMATIC) == 0);
}

sub is_none_quoting { 
	return(($_[0][ATB_PROPERTIES] & QTG_NONE) > 1);
}

sub is_completed_stage { 
	return(($_[0][ATB_PROPERTIES] & STG_COMPLETED) == 0);
}

sub is_prototype_stage { 
	return(($_[0][ATB_PROPERTIES] & STG_PROTOTYPE) > 1);
}

sub is_temporary_lifespan { 
	return(($_[0][ATB_PROPERTIES] & LSP_TEMPORARY) == 0);
}

sub is_permanent_lifespan { 
	return(($_[0][ATB_PROPERTIES] & LSP_PERMANENT) > 1);
}

sub build_arguments {
	my ($self) = (shift);

	my @arguments = ();
	foreach my $parameter (@_) {
		my $method = "get_$parameter";
		push(@arguments, $self->$method());
	}
	return(@arguments);
}

sub get_id { return($_[0][ATB_ID]); }
sub get_name { return($_[0][ATB_NAME]); }
sub get_name_short { $_[0][ATB_NAME] =~ m,^(\w+_)?(.*)$,; return($2); }
sub get_name_lc { return(lc($_[0][ATB_NAME])); }
sub get_value { return($_[0][ATB_VALUE]); }
sub get_representation {

	if (($_[0][ATB_PROPERTIES] & QTG_NONE) > 1) {
		return($_[0][ATB_VALUE]);
	}

	my $value = $_[0][ATB_VALUE];
	if (ref($value) eq 'SCALAR') {
		if (defined($$value)) {
			$value =~ s,\\,\\\\,sg;
			$value =~ s,\},\\},sg;
			return("\\q{$$value}");
		} else {
			return('\undef');
		};
	} else {
		if (defined($value)) {
			$value =~ s,\\,\\\\,sg;
			$value =~ s,\},\\},sg;
			return("q{$value}");
		} else {
			return('undef');
		};
	}
}


1;
