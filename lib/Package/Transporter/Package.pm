package Package::Transporter::Package;
use strict;
use warnings;
use Carp qw();

use Package::Transporter sub{eval shift};
use Package::Transporter::Symbols;
use Package::Transporter::Application;

our $DEBUG = 0;
our $AUTOLOAD;
sub AUTOLOAD {
	Package::Transporter::_AUTOLOAD(sub{eval shift}, __PACKAGE__, 'Symbol',
		$AUTOLOAD, @_)
}

sub ATB_NAME() { 0 };
sub ATB_VISIT_POINT() { 1 };
sub ATB_SYMBOLS() { 2 };
sub ATB_APPLICATIONS() { 3 };
sub ATB_TRANSACTION() { 4 };
sub ATB_CLEANUP_CODE() { 5 };

my @EXPORT = qw(ATB_NAME ATB_VISIT_POINT ATB_SYMBOLS ATB_APPLICATIONS
	ATB_TRANSACTION ATB_CLEANUP_CODE);
sub import {
	return(Package::Transporter::_import_subroutines((caller())[0], \@EXPORT, @_));
}

sub new {
	my ($class, $name) = (shift, shift);

	my $self = [$name,			#ATB_NAME
		undef,				#ATB_VISIT_POINT
		Package::Transporter::Symbols->new(),	#ATB_SYMBOLS
		[],				#ATB_APPLICATIONS
		undef,				#ATB_TRANSACTION
		'',				#ATB_CLEANUP_CODE
		];
	bless($self, $class);
	Internals::SvREADONLY(@{$self}, 1);

	return($self);
}


#my %EXPORT_READY = ();
sub set_visit_point {
	my ($self, $visit_point) = @_;

	if (ref($visit_point) ne 'CODE') {
		Carp::confess("Don't know what to do with argument '$visit_point'.\n");
	}

	$self->[ATB_VISIT_POINT] = $visit_point;

#	unless (exists($EXPORT_READY{$self->[ATB_NAME]})) {
#		$EXPORT_READY{$self->[ATB_NAME]} = 1;
#		$visit_point->(\q{my @TRANSPORTER_DATA_EXPORT = (); });
#	}

	return;
}


sub symbols { return($_[0][ATB_SYMBOLS]); }


sub application { # definition
	my ($self) = (shift);

	my $application = Package::Transporter::Application->new(@_);
	$self->add_application($application);
	return;
}


sub add_application {
	my ($self, $application) = (shift, shift);

	if ($self->[ATB_NAME] eq '*') {
		push(@{$self->[ATB_APPLICATIONS]}, $application);
		return;
	}

#	if ($application->is_universal_propagation()) {
#		Package::Transporter::add_universal($self, $application);
#	} else {
		push(@{$self->[ATB_APPLICATIONS]}, $application);
#	}

	if ($application->is_instant_implementation()) {
		my @transaction = $application->apply($self->[ATB_SYMBOLS]);
		$self->submit(@transaction);
	}

	return;
}

 
sub lookup_applications {
	my ($self, $properties) = (shift, shift);

	my @applications = ();
	foreach my $application (@{$self->[ATB_APPLICATIONS]}) {
		next unless ($application->has_properties($properties));
		push(@applications, $application);
	}
	return(\@applications);
}


sub selected_symbols { return($_[1]->selected_symbols($_[0][ATB_SYMBOLS])); }
sub add_symbols { shift->[ATB_SYMBOLS]->add(@_); return; }


sub minimize {
	my ($self) = (shift);

	if (defined($self->[ATB_CLEANUP_CODE])) {
		$self->transport(\$self->[ATB_CLEANUP_CODE]);
		$self->[ATB_CLEANUP_CODE] = '';
	}
	$self->[ATB_SYMBOLS]->remove_temporary();

	return;
}


# sub data_export {
# 	my ($self) = (shift);
# 
# 	my $vehicle = sprintf('vehicle_%s_%08x', time(), int(rand(2**32-1)));
# 
# 	my $get_data = q{ return(join(', ', @TRANSPORTER_DATA_EXPORT)); };
# 	my $data = $self->transport(\$get_data);
# 
# 	my $load_data = sprintf('our @%s = (%s);', $vehicle, $data);
# 	$self->transport(\$load_data);
# 
# 	$vehicle = $self->[ATB_NAME].'::'.$vehicle;
# 	return($vehicle, $data);
# }
# 
# 
# sub data_import {
# 	my ($self, $vehicle, $data) = (shift, shift, shift);
# 
# 	my $unload_data = sprintf('(%s) = splice(@%s);', $data, $vehicle);
# 	$self->transport(\$unload_data);
# 	return;
# }
# 
# 
# sub data_clear {
# 	my ($self, $vehicle) = (shift, shift);
# 
# 	my $clear_data = sprintf('undef @%s;', $vehicle);
# 	$self->transport(\$clear_data);
# 	return;
# }


sub mix_along_hierarchy {
	my ($self) = (shift);

	my $path = $self->[ATB_NAME];
	my @hierarchy = ();
	while($path =~ s,::\w+$,,s) {
		push(@hierarchy, $path);
	}
#	if($DEBUG) {
#		print STDERR "Attempting to mix packages (", join(' / ', @hierarchy), ")\n";
#	}
	
	Package::Transporter::mix_implicit($self, @hierarchy);
	return;
}


sub mix_along_isa {
	my ($self) = (shift);

	# ready for lexically scoped @ISA
	my $return_isa = sprintf('return(@%s::ISA);', $self->[ATB_NAME]);
	my @isa = $self->transport(\$return_isa);

	Package::Transporter::mix_implicit($self, @isa);
	return;
}


sub mix_in_main { # just a placeholder
	Package::Transporter::mix_implicit($_[0], 'main');
	return;
}


sub mix_in {
	Package::Transporter::mix_implicit($_[0], @_);
	return;
}


sub mix_in_explicit {
	Package::Transporter::mix_explicit($_[0], @_);
	return;
}


sub retrieve {
	my ($self) = (shift);
	
	my @values = map($self->[ATB_SYMBOLS]->lookup_name($_)->get_value(), 
		@_);
	return(@values);
}

sub assign {
	my ($self) = (shift);

	my $symbols = $self->[ATB_SYMBOLS];
	while(defined(my $name = shift)) {
		last unless (exists($_[0]));
		my $found = $symbols->lookup_name($name);

		unless (scalar(@$found)) {
			Carp::confess("No such symbol '$name' in package '$self->[ATB_NAME]'.");
		}
		$_[0] = $found->get_value();
		shift;
	}
	return;
}


sub transport {
	my $subeval = $_[0][ATB_VISIT_POINT];
	unless (defined($subeval)) {
		Carp::confess("Missing subeval in package '$_[0][ATB_NAME]'.\n");
	}
	unless (defined($_[1])) {
		Carp::confess("No code.\n");
	}
	unless (ref($_[1]) eq 'SCALAR') {
		Carp::confess("Code not a scalar ref.\n");
	}

	my $rv = $subeval->(${$_[1]});
	if ($@) {
		print STDERR "Offending Code:\n", ${$_[1]}, "\n";
		Carp::confess($@);
	}
        return($rv);
}


sub submit {
	if (defined($_[0][ATB_TRANSACTION])) {
		$_[0][ATB_TRANSACTION][0] .= ${$_[1]};
		$_[0][ATB_TRANSACTION][1] .= ${$_[2]};
	} else {
		$_[0]->transport($_[1]);
		$_[0][ATB_CLEANUP_CODE] .= ${$_[2]} if (exists($_[2]));
	}
        return;
}


sub start_transaction {
	my ($self) = (shift);

	if (defined($self->[ATB_TRANSACTION])) {
		Carp::confess('Transaction already started.');
	}
	$self->[ATB_TRANSACTION] = ['', ''];
        return;
}


sub commit {
	my ($self) = (shift);

	unless (defined($self->[ATB_TRANSACTION])) {
		Carp::confess('No transaction started.');
	}
	
	my $transaction = $self->[ATB_TRANSACTION];
	$self->[ATB_TRANSACTION] = undef;
	$self->submit(@$transaction);

        return;
}


sub rollback {
	my ($self) = (shift);

	unless (defined($self->[ATB_TRANSACTION])) {
		Carp::confess('No transaction started.');
	}
	$self->[ATB_TRANSACTION] = undef;
        return;
}


sub DESTROY {
	if (defined($_[0][ATB_TRANSACTION]) and length($_[0][ATB_TRANSACTION])) {
		Carp::confess('Missing commit()?');
	}
	return;
}



1;
