package Package::Transporter::Hierarchy::Universal;
use strict;
use warnings;
#use Carp qw();
use Scalar::Util;
use parent qw(
	Package::Transporter::Hierarchy
);

# return all generators found
sub lookup {
	my ($self, $pkg_list, $pkg_name) = (shift, shift, shift);

	my @generators = ();
	foreach my $pkg_prefix (@$pkg_list) {
		next unless (exists($self->{$pkg_prefix}));
		push(@generators, @{$self->{$pkg_prefix}{''}});
	}
	return(\@generators);
}

#sub DESTROY {
#	use Data::Dumper;
#	print STDERR Dumper($_[0]);
#}

1;
