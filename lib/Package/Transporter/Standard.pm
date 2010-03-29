package Package::Transporter::Standard;
use strict;
use warnings;
use Carp qw();
use Scalar::Util qw();
#use MRO::Compat;
use mro;
use parent qw(
	Package::Transporter::Package
);

sub ATB_PKG_NAME() { 0 };
sub ATB_VISIT_POINT() { 1 };
sub ATB_SEARCH_PATH() { 2 };
sub ATB_PATH_PARTITION() { 3 };
sub ATB_EXISTING() { 4 };
sub ATB_MY_AUTOLOAD() { 5 };

use Package::Transporter::Rule::Standard;
use Package::Transporter::Hierarchy::Potential; 
use Package::Transporter::Hierarchy::Drain; 
use Package::Transporter::Hierarchy::Universal; 
use Package::Transporter::Path_Partition;
use Package::Transporter::Generator;
use Package::Transporter::Generator::Potential::Anonymous;

my %HIERARCHIES = (
	'potential' => Package::Transporter::Hierarchy::Potential->new(),
	'drain' => Package::Transporter::Hierarchy::Drain->new(),
	'universal' => Package::Transporter::Hierarchy::Universal->new(),
);

my $universal_autoload = undef;

our $OVERWRITE //= 0;
our $DEBUG //= 0;
Internals::SvREADONLY($DEBUG, 1);
sub DEBUG() { $DEBUG };

my $generator_class = 'Package::Transporter::Generator';
my $autoloadcan = q{
	my $object = shift(@_);

	our $AUTOLOAD;
	sub AUTOLOAD {
		my $sub_ref = $object->autoload($AUTOLOAD, @_);
		goto &$sub_ref if (defined($sub_ref));
	}
	sub can {
		return(UNIVERSAL::can(@_) // $object->can_already(@_));
	}
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

sub package_hierarchy {
	my $name = shift;
	my @hierarchy = ($name);
	while($name =~ s,\w+(::)?$,,s) {
		push(@hierarchy, $name);
	}
	return(\@hierarchy);
}

sub new {
	my ($class, $pkg_name, $visit_point) = @_;

	my $search = package_hierarchy($pkg_name);
	my $self = [
		$pkg_name, 
		$visit_point,
		Package::Transporter::Path_Partition->new($search)
	];
	bless($self, $class);

	my $existing = "$pkg_name\::AUTOLOAD";
	if(defined(&$existing)) {
		if($OVERWRITE) {
			$self->[ATB_EXISTING] = \&$existing;
		} else {
			Carp::confess("The subroutine '$existing' already exists.");
		}
	}
	$visit_point->($autoloadcan, $self);
	if(DEBUG) {
		$self->[ATB_MY_AUTOLOAD] = \&$existing;
	}
	

	Internals::SvREADONLY(@{$self}, 1);
	return($self);
}

sub become {
	my ($self, $class) = @_;
	Internals::SvREADONLY(@{$self}, 0);
	bless($self, $class);
	return;
}

sub search { return($_[0][ATB_PATH_PARTITION]); };

sub register_potential {
	my ($self, $potential) = (shift, shift);

	if (scalar(@_) == 0) { # no further arguments
		if (ref($potential) eq 'ARRAY') {
			$potential = Package::Transporter::Rule::Standard->new(@$potential);
			$HIERARCHIES{'potential'}->register_rules($potential, $potential->pre_select);
		} elsif (Scalar::Util::blessed($potential)) {
			$HIERARCHIES{'potential'}->register_rules($potential, $potential->pre_select);
		} else {
			Carp::confess("Wrong type of argument.");
		}
		return($potential);
	}

	my $generator = $self->recognize($potential, '::Potential');

	my @pkg_names = ($self->[ATB_PKG_NAME]);
	my $wild_card = shift;
	if ($wild_card eq 'FOR_SELF') {
#	} elsif ($wild_card eq 'FOR_FAMILY') {
#		Carp::confess("In the context of potential, there is no wild_card 'FOR_FAMILY'.\n");
	} elsif ($wild_card eq 'FOR_BRANCH_SELF') {
		push(@pkg_names, $pkg_names[0]);
		$pkg_names[1] .= '::';
	} elsif ($wild_card eq 'FOR_BRANCH') {
		$pkg_names[0] .= '::';
	} elsif ($wild_card eq 'FOR_ANY') {
		$pkg_names[0] = '';
	} else {
		Carp::confess("Don't know what to do with wild_card '$wild_card'.\n");
	}
	
	unless (defined($_[0])) {
		if ($generator->can('matcher')) {
			$_[0] = $generator->matcher();
		}
	}
	
	$potential = Package::Transporter::Rule::Standard->new($generator, \@pkg_names, @_);
		use Data::Dumper;
#		print STDERR Dumper($potential);

	$HIERARCHIES{'potential'}->register_rules($potential, $potential->pre_select);

	return($potential);
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
		Carp::confess("Got a request to handle subroutine '$sub_name' for foreign package '$1' in package '$pkg_name'.");
#		$AUTOLOAD = "$1::$sub_name";
#		universal_autoload($self, @_);
	}
	return(undef) if ($sub_name eq 'DESTROY');
#	return(undef) if ($sub_name eq 'AUTOLOAD');
#	return(undef) if ($sub_name eq '(un)import'); # automatically skipped
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
	return($HIERARCHIES{'potential'}->lookup_rule(
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


sub register_drain {
	my ($self, $drain, $wild_card, $prefix) = (shift, shift, shift, shift);
# no rules, because it is about properties

	my $generator = $self->recognize($drain, '::Drain');

	my $pkg_name = $self->[ATB_PKG_NAME];
	if ($wild_card eq 'FOR_SELF') {
		$pkg_name .= '<<';
	} elsif ($wild_card eq 'FOR_FAMILY') {
		$pkg_name .= '||';
	} elsif ($wild_card eq 'FOR_BRANCH_SELF') {
		$pkg_name .= '<>';
	} elsif ($wild_card eq 'FOR_BRANCH') {
		$pkg_name .= '>>';
	} elsif ($wild_card eq 'FOR_ANY') {
		$pkg_name = '>>';
	} else {
		Carp::confess("Don't know what to do with wild_card '$wild_card'.\n");
	}
	$HIERARCHIES{'drain'}->register_rule($generator, $pkg_name, $prefix);
	$generator->configure(@_);

	return($generator);
}

sub implement_drain {
	my ($self) = @_;

	my $pkg_name = $self->[ATB_PKG_NAME];
	my $generators = $HIERARCHIES{'drain'}->collect_generators(
		$self->[ATB_SEARCH_PATH],
		mro::get_linear_isa($pkg_name),
		$pkg_name);

	while(my ($prefix, $types) = each(%$generators)) {
		while(my ($type, $line) = each(%$types)) {
			my @data = map(@{$_->get_data}, @$line);
			my $main = shift(@$line);
			$main->run($self, $pkg_name, $prefix, \@data);
		}
	}

	$HIERARCHIES{'drain'}->release($self->[ATB_PKG_NAME]);

	return;
}

my $installed = 0;
sub register_universal {
	my ($self, $universal, $pkg_names) = (shift, shift, shift);

	unless($installed) {
		$installed = 1;
		*UNIVERSAL::AUTOLOAD = sub {
			my $sub_ref = universal_autoload($self, @_);
			goto &$sub_ref if (defined($sub_ref));
		};
		*UNIVERSAL::DESTROY = sub {};
	}

	my $generator = $self->recognize($universal, '::Universal');
	$HIERARCHIES{'universal'}->register_rule($generator, $pkg_names, '');

	return($generator);

}

our $AUTOLOAD;
sub universal_autoload {
	my ($self) = (shift);

	unless($AUTOLOAD =~ m,^(.*)::(\w+)$,) {
		Carp::confess("Can't recognize '$AUTOLOAD'.");
	}
	my ($pkg_name, $sub_name) = ($1, $2);

	my $search = package_hierarchy($pkg_name);
	my $generators = $HIERARCHIES{'universal'}->lookup($search, $pkg_name);
	foreach my $generator (@$generators) {
		my $rv = $generator->run($self, $pkg_name, $sub_name, @_);
		return($rv) if(defined($rv));
	}

        return;
}

if(DEBUG) {
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
	}
}

1;
