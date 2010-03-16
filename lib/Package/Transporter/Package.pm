package Package::Transporter::Package;
use strict;
use warnings;
use Carp qw();
use Scalar::Util qw();
#use MRO::Compat;
use mro;

sub ATB_PKG_NAME() { 0 };
sub ATB_VISIT_POINT() { 1 };
sub ATB_SEARCH_PATH() { 2 };
sub ATB_PATH_PARTITION() { 3 };
sub ATB_EXISTING() { 4 };
sub ATB_MY_AUTOLOAD() { 5 };

use Package::Transporter::Rule::Standard;
use Package::Transporter::Pre_Selection;
use Package::Transporter::Path_Partition;
use Package::Transporter::Generator;
use Package::Transporter::Generator::Anonymous;

my $RULES = Package::Transporter::Pre_Selection->new(); 

our $OVERWRITE //= 0;
our $DEBUG //= 0;

my $generator_class = 'Package::Transporter::Generator';
my $autoloadcan = q{
	my $object = shift(@_);

	our $AUTOLOAD;
	sub AUTOLOAD {
		my $sub_ref = $object->autoload($AUTOLOAD, @_);
		goto &$sub_ref if (defined($sub_ref));
	}
#	Internals::SvREADONLY(&AUTOLOAD, 1);
	sub can {
		return(UNIVERSAL::can(@_) // $object->can_already(@_));
	}
	*__ = \&Package::Transporter::__;
};

my $potentially_can = q{
	my $object = shift(@_);
	sub potentially_can {
		return($object->potentially_can(@_));
	}
	return(\&potentially_can);
};

my $potentially_defined = q{
	my $object = shift(@_);
	sub potentially_defined(\&) {
		return($object->potentially_defined(@_));
	}
	return(\&potentially_defined);
};

sub new {
	my ($class, $pkg_name, $visit_point) = @_;

	my $self = [
		$pkg_name, 
		$visit_point,
		Package::Transporter::Path_Partition->new($pkg_name)
	];
	bless($self, $class);

	my $existing = "$pkg_name\::AUTOLOAD";
	if(defined(&$existing)) {
		if($OVERWRITE) {
			push(@$self, \&$existing);
		} else {
			Carp::confess("The subroutine '$existing' already exists.");
		}
	}
	$visit_point->($autoloadcan, $self);
	if($DEBUG) {
		$self->[ATB_MY_AUTOLOAD] = \&$existing;
	}
	

	Internals::SvREADONLY(@{$self}, 1);
	return($self);
}

sub name { return($_[0][ATB_PKG_NAME]); };

sub search { return($_[0][ATB_PATH_PARTITION]); };

sub set_visit_point {
	$_[0][ATB_VISIT_POINT] = $_[1];
	return;
}

sub transport {
	my ($self, $code_ref) = (shift, shift);

#	unless (defined($code_ref)) {
#		Carp::confess("No code to transport?\n");
#	}
	unless (ref($code_ref) eq 'SCALAR') {
		Carp::confess("Code not a scalar reference.\n");
	}
	my $sa = $@;
	my $rv = $self->[ATB_VISIT_POINT]->($$code_ref, @_);
	if ($@) {
		my $msg = '';
		$msg .= "Offending Code:\n$$code_ref\n" unless($^S);
		$msg .= $@;
		Carp::confess($msg);
	}
	$@ = $sa;
	return($rv);
}

sub create_generator {
	my ($self, $rule) = (shift, shift);

	my $generator;
	if ($rule =~ m,(^|::)([\w_]+($|::))+,) {
		$generator = Package::Transporter::Generator::new_class($rule, $self, @_);
	} else {
		my $code = sprintf(q{
sub($$;@) {
	my($pkg, $sub_name, @args) = @_;
%s
}}, $rule);
		local $@;
		$rule = eval $code;
		Carp::confess($@) if ($@);
		$generator = Package::Transporter::Generator::Anonymous->new($rule);
	}
	return($generator);
}

sub register_potential {
	my ($self, $potential) = (shift, shift);

	if (scalar(@_) == 0) { # no further arguments
		if (ref($potential) eq 'ARRAY') {
			$potential = Package::Transporter::Rule::Standard->new(@$potential);
			$RULES->register_rules($potential, $potential->pre_select);
		} elsif (Scalar::Util::blessed($potential)) {
			$RULES->register_rules($potential, $potential->pre_select);
		} else {
			Carp::confess("Wrong type of argument.");
		}
		return($potential);
	}

	my $potential_ref = ref($potential);
	my $generator;
	if ($potential_ref eq '') {
		$generator = $self->create_generator($potential);
	} elsif ($potential_ref eq 'CODE') {
		$generator = Package::Transporter::Generator::Anonymous->new($potential);
	} else {
		$generator = $potential;
	}
	unless (Scalar::Util::blessed($generator) and $generator->can('run')) {
		Carp::confess("The result does not look like a generator.\n");
	}

	my @pkg_names = ($self->[ATB_PKG_NAME]);
	my $wildcard = shift;
	if ($wildcard eq 'FOR_SELF') {
#	} elsif ($wildcard eq 'FOR_FAMILY') {
#		Carp::confess("In the context of potential, there is no wildcard 'FOR_FAMILY'.\n");
	} elsif ($wildcard eq 'FOR_BRANCH_SELF') {
		push(@pkg_names, $pkg_names[0]);
		$pkg_names[1] .= '::';
	} elsif ($wildcard eq 'FOR_BRANCH') {
		$pkg_names[0] .= '::';
	} elsif ($wildcard eq 'FOR_ANY') {
		$pkg_names[0] = '';
	} else {
		Carp::confess("Don't know what to do with wildcard '$wildcard'.\n");
	}
	
	unless (defined($_[0])) {
		if ($generator->can('matcher')) {
			$_[0] = $generator->matcher();
		}
	}
	
	$potential = Package::Transporter::Rule::Standard->new($generator, \@pkg_names, @_);
	$RULES->register_rules($potential, $potential->pre_select);

	return($potential);
}

sub register_drain {
	my ($self, $drain) = (shift, shift);
# no rules, because it is about properties

	my $drain_ref = ref($drain);
	my $generator;
	if ($drain_ref eq '') {
		$generator = $self->create_generator("::Constant_Function$drain");
	} elsif ($drain_ref eq 'CODE') {
		$generator = Package::Transporter::Generator::Anonymous->new($drain);
	} else {
		$generator = $drain;
	}
	unless (Scalar::Util::blessed($generator) and $generator->can('run')) {
		Carp::confess("The result does not look like a generator.\n");
	}

	my $pkg_name = $self->[ATB_PKG_NAME];
	my $wildcard = shift;
	if ($wildcard eq 'FOR_SELF') {
		$pkg_name .= '<<';
	} elsif ($wildcard eq 'FOR_FAMILY') {
		$pkg_name .= '||';
	} elsif ($wildcard eq 'FOR_BRANCH_SELF') {
		$pkg_name .= '<>';
	} elsif ($wildcard eq 'FOR_BRANCH') {
		$pkg_name .= '>>';
	} elsif ($wildcard eq 'FOR_ANY') {
		$pkg_name = '>>';
	} else {
		Carp::confess("Don't know what to do with wildcard '$wildcard'.\n");
	}
	my $prefix = shift;
	$RULES->register_rule($generator, $pkg_name, $prefix);
	$generator->configure(@_);

	return($generator);
}

sub implement_drain {
	my ($self) = @_;

	my $generators = $RULES->collect_generators(
		$self->[ATB_SEARCH_PATH],
		mro::get_linear_isa($self->[ATB_PKG_NAME]),
		$self->[ATB_PKG_NAME]);

	while(my ($prefix, $types) = each(%$generators)) {
		while(my ($type, $line) = each(%$types)) {
			my $main = shift(@$line);
			$main->consume(@$line);
			$main->run($self, $self->[ATB_PKG_NAME], $prefix);
		}
	}

	$RULES->release($self->[ATB_PKG_NAME]);

	return;
}

sub implement_potential {
	my ($self, $sub_name) = (shift, shift);

        my $generator = $self->find_generator($sub_name);
        unless (defined($generator)) {
                return($generator_class->failure(undef, $sub_name,
			'package object: no rule found'));
        }

        return($generator->run($self, $self->[ATB_PKG_NAME], $sub_name));
}

sub autoload {
	my ($self, $sub_name) = (shift, shift);

	my $pkg_name = $self->[ATB_PKG_NAME];
	if (($sub_name =~ s,^(.*)::,,) and ($pkg_name ne $1)) {
		Carp::confess("($pkg_name ne $1)"); # assertion - goes soon
	}
	return(undef) if ($sub_name eq 'DESTROY');
#	return(undef) if ($sub_name eq 'AUTOLOAD');
	if ($sub_name eq 'potentially_can') {
		return($self->transport(\$potentially_can, $self));
	}
	if ($sub_name eq 'potentially_defined') {
		return($self->transport(\$potentially_defined, $self));
	}

	my $generator;
	if (Scalar::Util::blessed($_[0])
	or (defined($_[0]) and ($_[0] eq $pkg_name))) { # constructor?
		my $ISA = mro::get_linear_isa($pkg_name);
		($self, $generator) = Package::Transporter::find_generator($ISA, $sub_name, @_);
	} else {
		$generator = $self->find_generator($sub_name, @_);
	}

	unless (defined($generator)) {
		if($OVERWRITE and (scalar(@$self) == 5)) {
			$self->[ATB_EXISTING]->(@_);
		}
		return($generator_class->failure(undef, $sub_name,
			'package object: no rule found'));
	}
	return($generator->run($self, $pkg_name, $sub_name, @_));
}

sub find_generator {
	my ($self, $sub_name) = (shift, shift);
	return($RULES->lookup_rule(
		$self->[ATB_SEARCH_PATH],
		$self->[ATB_PKG_NAME],
		$sub_name, @_));
}

sub can_already {
	my ($self) = (shift);

	my $ISA = mro::get_linear_isa($self->[ATB_PKG_NAME]);
	my ($pkg, $generator) = Package::Transporter::find_generator($ISA, $_[1], $_[0]);
	return unless (defined($generator));
	return($generator->run($pkg, $self->[ATB_PKG_NAME], $_[1], @_));
}

sub potentially_can {
	my ($self) = (shift);

	my $ISA = mro::get_linear_isa($self->[ATB_PKG_NAME]);
	my ($pkg, $generator) = Package::Transporter::find_generator($ISA, $_[1], $_[0]);
	return(defined($generator));
}

sub potentially_defined {
	return(defined(shift->find_generator(@_)));
}

if($DEBUG) {
	eval q{
sub DESTROY {
	my $self = shift;
	if(scalar(@$self) == 6) {
		my $existing = $self->[ATB_PKG_NAME]."::AUTOLOAD";
		if($self->[ATB_MY_AUTOLOAD] ne \&$existing) {
			Carp::confess("Something modified the AUTOLOAD I installed.");
		}
	}
}
	};
}

1;
