package Package::Transporter::Symbols;
use strict;
use warnings;
use Package::Transporter sub{eval shift};

sub new {
	my ($class) = (shift);

	my $self = {};
	bless($self, $class);
	return($self);
}


sub add {
	my ($self, $symbols) = (shift, shift);

	foreach my $symbol (@$symbols) {
		my $name = $symbol->get_name();
		if (exists($self->{$name}) and $self->{$name}->is_completed_stage()) {
			Carp::confess("Symbol '$name' already exists.");
		}
		$self->{$name} = $symbol;
	}
	return;
}


sub complement {
	my ($self, $symbols) = (shift, shift);

	foreach my $symbol (@$symbols) {
		my $name = $symbol->get_name();
		next if (exists($self->{$name}));
		$self->{$name} = $symbol;
	}
	return;
}


sub remove {
	my ($self) = (shift);

	foreach my $name (@_) {
		next unless (exists($self->{$name}));
		delete($self->{$name});
	}
	return;
}


sub remove_temporary {
	my ($self) = (shift);

	foreach my $key (keys(%$self)) {
		next if ($self->{$key}->is_permanent_lifespan());
		delete($self->{$key});
	}
	return;
}


sub exists { CORE::exists($_[0]->{$_[1]}); }

sub count { scalar(CORE::keys(%{$_[0]})); }


sub lookup_name {
	my ($self, $key) = (shift, shift);

	unless (exists($self->{$key})) {
		Carp::confess("Missing symbol '$key'.");
	}
	return($self->{$key});
}


sub lookup_prefixed {
	my ($self, $prefix) = @_;

	my $l = length($prefix);
	my @symbols = ();
	foreach my $key (keys(%$self)) {
		next if ($l and (substr($key, 0, $l) ne $prefix));
		push(@symbols, $self->{$key});
	}
	return(\@symbols);
}


1;