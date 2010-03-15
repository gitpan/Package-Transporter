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
	if(exists($self->[ATB_DST_PKG])) {
		my $class_file = $self->[ATB_DST_PKG];
		$class_file =~ s,::,/,sg;
		$class_file .= '.pm';
		require $class_file;
	} else {
		$self->[ATB_DST_PKG] = undef;
	}
	return;
}

sub implement {
	my ($self, $pkg, $sub_name) = (shift, shift, shift);

	my $defining_pkg = $self->[ATB_DST_PKG] // $self->[ATB_PKG]->name;
	my $sub_text = sprintf(q{
my ($only_defined_originals) = (shift(@_));
if ($only_defined_originals and !defined(&%s::%s)) {
	return(Package::Transporter::Generator::failure('%s', '%s', '::Export [original does not exist]'));
}
my $sub_ref = \&%s::%s;
*%s = $sub_ref;
return($sub_ref);
		}, 
		$defining_pkg, $sub_name,
		$defining_pkg, $sub_name,
		$defining_pkg, $sub_name,
		$sub_name);

	return($pkg->transport(\$sub_text, $ONLY_DEFINED_ORIGINALS));
}

sub matcher {
	my ($self) = (shift);

	return unless($ONLY_DEFINED_ORIGINALS);
	my $defining_pkg = $self->[ATB_DST_PKG] // $self->[ATB_PKG]->name;

	return(sub {
		my $fqsn = "$defining_pkg::$_[1]";
		return(defined(&$fqsn));
	});
}
1;
