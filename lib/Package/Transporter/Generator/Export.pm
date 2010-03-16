package Package::Transporter::Generator::Export;
use strict;
use warnings;
use parent qw(
	Package::Transporter::Generator
);
# allow AUTOLOAD to eventually trigger AUTOLOAD? (1 means no)
our $ONLY_DEFINED_ORIGINALS = 1;

sub ATB_PKG() { 0 };
sub ATB_DST_PKG() { 1 };

sub _init {
	my $self = shift;

	my @pkg_names = splice(@$self, 1);
	if(scalar(@pkg_names)) {
		$self->[ATB_DST_PKG] = \@pkg_names;
		foreach my $pkg_name (@pkg_names) {
			my $class_file = $pkg_name;
			$class_file =~ s,::,/,sg;
			$class_file .= '.pm';
			require $class_file;
		}
	} else {
		$self->[ATB_DST_PKG] = [$self->[ATB_PKG]->name];
	}
	return;
}

sub implement {
	my ($self, $pkg, $sub_name) = (shift, shift, shift);

	my $defining_pkg;
	foreach my $pkg_name (@{$self->[ATB_DST_PKG]}) {
		my $fqsn = "$pkg_name\::$sub_name";
		next unless (defined(&$fqsn));
		$defining_pkg = $pkg_name
	}
	if ($ONLY_DEFINED_ORIGINALS and !defined($defining_pkg)) {
		return(Package::Transporter::Generator::failure(undef, $sub_name, '::Export [original does not exist]'));
	}

	my $sub_text = sprintf(q{
my $sub_ref = \&%s::%s;
*%s = $sub_ref;
return($sub_ref);
		}, 
		$defining_pkg, $sub_name,
		$sub_name);

	return($pkg->transport(\$sub_text));
}

sub matcher {
	my ($self) = (shift);

	return unless($ONLY_DEFINED_ORIGINALS);
	return(sub {
		foreach my $pkg_name (@{$self->[ATB_DST_PKG]}) {
			my $fqsn = "$pkg_name\::$_[1]";
			return(1) if (defined(&$fqsn));
		}
		return;
	});
}

1;
