package Package::Transporter;
use strict;
use warnings;
use Carp qw();

our $VERSION = '0.02';
our $DEBUG = 0;

my @EXPORT = qw(QTG_AUTOMATIC QTG_NONE LSP_TEMPORARY LSP_PERMANENT 
	STG_COMPLETED STG_PROTOTYPE
	IMP_INSTANT IMP_ON_DEMAND UND_NEVER UND_TRIGGERED
	SCP_PRIVATE SCP_PUBLIC MIX_EXPLICIT MIX_IMPLICIT PRP_LOCAL
	PRP_UNIVERSAL);

# symbol properties

sub QTG_AUTOMATIC() { 0+2**1 };
sub QTG_NONE() { 1+2**1 };

sub LSP_TEMPORARY() { 0+2**2 };
sub LSP_PERMANENT() { 1+2**2 };

sub STG_COMPLETED() { 0+2**3 };
sub STG_PROTOTYPE() { 1+2**3 };

# applications properties - not restarting count

sub SCP_PRIVATE() { 0+2**4 };
sub SCP_PUBLIC() { 1+2**4 };

sub MIX_EXPLICIT() { 0+2**5 };
sub MIX_IMPLICIT() { 1+2**5 };

sub IMP_INSTANT() { 0+2**6 };
sub IMP_ON_DEMAND() { 1+2**6  };

sub UND_NEVER() { 0+2**7 };
sub UND_TRIGGERED() { 1+2**7 };

sub PRP_LOCAL() { 0+2**8 };
sub PRP_UNIVERSAL() { 1+2**8 };

sub UPD_NONE() { 0+2**9 }; # reserved
sub UPD_AUTOMATIC() { 1+2**9 }; # reserved


require Package::Transporter::Package;
our $PACKAGES = {};
$PACKAGES->{'*'} = Package::Transporter::Package->new('*');

my $obtain = sub {
	my $name = shift;
	unless (exists($PACKAGES->{$name})) {
		$PACKAGES->{$name} = Package::Transporter::Package->new($name);
	}
	my $pkg = $PACKAGES->{$name};

	if (exists($_[0])) {
		if (ref($_[0]) eq 'CODE') {
			$pkg->set_visit_point(shift);
		} else {
			Carp::confess("Don't know what to do with argument $_[0].\n");
		}
	}

	return($pkg);
};


sub new {
	my ($class) = (shift);

	my $pkg = $obtain->((caller())[0], @_);
	return($pkg);
}


sub drop {
	my ($class) = (shift);

	my $name = (caller())[0];
	if (exists($PACKAGES->{$name})) {
		$PACKAGES->{$name}->minimize(@_);
		delete($PACKAGES->{$name});
	}
}


sub package_vs_file_name {
        my ($pkg_name, $file_name, undef) = @_;

        my @pkg_path = reverse(split('::', $pkg_name));
        $file_name =~ s/\.pm$//s;
        my @file_path = reverse(split('/', $file_name));
        foreach my $pkg_element (@pkg_path) {
                my $file_element = shift(@file_path);
                next if ($pkg_element eq $file_element);
                Carp::confess("$pkg_name: Names of .pm file and package name do not match:
 $pkg_element vs. $file_element\n");
        }
        return;
}


sub mix_explicit {
	my ($pkg1, $name) = (shift, shift);

	unless (exists($PACKAGES->{$name})) {
		Carp::confess("No package '$name'.");
	}
	my $pkg2 = $PACKAGES->{$name};

	my @applications = ();
	foreach my $name (@_) {
		my $application = $pkg2->application_by_name($name);
		next if ($application->is_public_scope());
		push(@applications, $application);
	}
	_mix($pkg1, $pkg2, @applications);
}


sub mix_implicit($$@) {
	my ($pkg1, $scope) = (shift, shift);

	foreach my $name (@_) {
		unless (exists($PACKAGES->{$name})) {
			Carp::confess("No package '$name'.");
		}
		my $pkg2 = $PACKAGES->{$name};
		my $applications = $pkg2->lookup_applications([$scope, MIX_IMPLICIT]);
		_mix($pkg1, $pkg2, @$applications);
	}
}


sub _mix($$) {
	my ($pkg1, $pkg2) = (shift, shift);

	my $properties = [SCP_PRIVATE, MIX_EXPLICIT, PRP_LOCAL];
	foreach my $application (@_) {
		my $selected = $pkg2->selected_symbols($application);

		$pkg1->import_symbols($selected);
		my $clone = $application->clone();
		if ($pkg1 ne $PACKAGES->{'*'}) {
			$clone->set_properties($properties);
		}
		$pkg1->add_application($clone);
	}

#FIXME: we're running in BEGIN {..} - no (lexically scoped) variable, yet
#	return if (($pkg1 eq $PACKAGES->{'*'}) or ($pkg2 eq $PACKAGES->{'*'}));
#	my ($vehicle, $data) = $pkg2->data_export();
#	$pkg1->data_import($vehicle, $data);
#	$pkg2->data_clear($vehicle);
}


sub add_universal($$) {
	my ($pkg2, $application) = (shift, shift);

	my $pkg1 = $PACKAGES->{'*'};
	my $selected = $pkg2->selected_symbols($application);
	$pkg1->import_symbols($selected);
	$pkg1->add_application($application);
}


sub import($@) {
	my ($class) = (shift);

	package_vs_file_name(caller()) if ($DEBUG);
	return unless (exists($_[0]));
	my $subeval = shift;

	my $caller0 = (caller())[0];
	_import_subroutines($caller0, \@EXPORT, $class, $subeval);

	return if ($caller0 =~ m,Package::Transporter::,s);

	my $pkg = $obtain->($caller0, $subeval);
	mix_implicit($pkg, PRP_UNIVERSAL, '*');
}

#my %HELPERS = ();
sub _import_subroutines {
	my ($caller0, $EXPORT, $class, $subeval) = (shift, shift, shift, shift);
	
	return unless (ref($subeval) eq 'CODE');
	my $defines = join("\n",
		map(sprintf('*%s = \&%s::%s; ', $_, $class, $_), 
			@$EXPORT));

	if ($class eq 'Package::Transporter') {
		my $undefines = join("\n", map(sprintf('undef &%s;', $_), @$EXPORT));
		$defines .= "sub transporter_cleanup_constant_functions() {\n$undefines\n}\n";
	}
#	print STDERR "def: $defines\n";

	$subeval->($defines);
	Carp::confess($@) if ($@);
}


sub binary_properties($$$) {
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


sub get_package_path($) {
	my $__PACKAGE__ = shift;
	my $cloc = rindex($__PACKAGE__, '::'); # -1 is overloaded semantically
	my $package_path = substr($__PACKAGE__, 0, ($cloc == -1) ? 0 : $cloc);
	return($package_path);
};


#sub state {
#	use Data::Dumper;
#	print STDERR Dumper($PACKAGES);
#}

sub _AUTOLOAD {
	my ($subeval, $__PACKAGE__, $folder, $fqsn) = (shift, shift, shift, shift);

	if ($fqsn !~ m,^${__PACKAGE__}::(\w+)$,si) {
		Carp::confess("Subroutine '$fqsn' has an illegal name.");
	}
	my $name = lc($1);
	if (exists(&$name)) {
		Carp::confess("$fqsn: Subroutine '$name' is already defined.");
	}
	my $source = join('::', get_package_path($__PACKAGE__), $folder, $name);
	$source =~ s,([^a-zA-Z])([a-z]),$1.uc($2),sge;

	my $code = sprintf('use %s;
*%s = my $target = \&%s::%s;
return($target);', $source, $name, $source, $name, $source);
	my $target = $subeval->($code);
	Carp::confess($@) if ($@);
	unless (defined($target)) {
		Carp::confess("Loading of package '$source' to generate method '$name' failed.");
	}

        goto &$target;
}


1;
