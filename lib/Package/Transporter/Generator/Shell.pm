package Package::Transporter::Generator::Shell;
use strict;
use warnings;
BEGIN { require Shell; };
use parent qw(
	Package::Transporter::Generator
);

sub ATB_PKG() { 0 };
sub ATB_DST_PKG() { 1 };
my $prefix = 'shell_';

sub implement {
	my ($self, $pkg, $sub_name) = (shift, shift, shift);

	unless($sub_name =~ m,^$prefix(\w+)$,) {
		return($self->failure(undef, $sub_name, "::Shell ['$sub_name' not matching '$prefix(\\w+)']"));

	}
	my $cmd = $1;
	return(Shell::_make_cmd($cmd));
}

sub matcher {
	return(sub { return(substr($_[2], 0, 6) eq $prefix); });
}

1;
