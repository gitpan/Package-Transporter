package Package::Transporter::Generator::Export;
use strict;
use warnings;
use parent qw(
	Package::Transporter::Generator
);
# allow AUTOLOAD to eventually trigger AUTOLOAD?
our $ONLY_DEFINED_ORIGINALS = 1;

sub ATB_PKG() { 0 };

sub implement {
	my ($self, $pkg, $sub_name) = (shift, shift, shift);

	my $defining_pkg = $self->[ATB_PKG];
	my $sub_text = sprintf(q{
my ($only_defined_originals) = (shift(@_));
if ($only_defined_originals and !defined(&%s::%s)) {
	return(Package::Transporter::Generator::failure('%s', '%s', '::Export [original does not exist]'));
}
my $sub_ref = \&%s::%s;
*%s = $sub_ref;
return($sub_ref);
		}, 
		$defining_pkg->name, $sub_name,
		$defining_pkg->name, $sub_name,
		$defining_pkg->name, $sub_name,
		$sub_name);

	return($pkg->transport(\$sub_text, $ONLY_DEFINED_ORIGINALS));
}

1;
