package Package::Transporter::Generator::Homonymous;
use strict;
use warnings;
use Carp qw();


my %DIRECTORIES = ();
sub pkg_file($) {
	my ($self, $pkg_name) = (shift, shift);

	if (exists($DIRECTORIES{$pkg_name})) {
		return($DIRECTORIES{$pkg_name});
	}
	my $pkg_file = $pkg_name;
	$pkg_file =~ s,::,/,sg;
	$pkg_file .= '.pm';

	$DIRECTORIES{$pkg_name} = $pkg_file;
	return($pkg_file);
}

sub read_file {
        open(F, '<', $_[1]) || Carp::confess("$_[1]: open/r: $!\n");
        read(F, $_[2], (stat(F))[7]) || Carp::confess("$_[1]: read: $!\n");
        close(F);
        return;
}

1;
