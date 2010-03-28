package Package::Transporter::Hierarchy::Potential;
use strict;
use warnings;
#use Carp qw();
use Scalar::Util;
use parent qw(
	Package::Transporter::Hierarchy
);

sub lookup_rule {
	my ($self, $pkg_list, $pkg_name, $sub_name) =
		(shift, shift, shift, shift);

	foreach my $pkg_prefix (@$pkg_list) {
		next unless (exists($self->{$pkg_prefix}));
		my $pkg_rules = $self->{$pkg_prefix};

		my $sub_rules = undef;
		if (exists($pkg_rules->{$sub_name})) {
			$sub_rules = $pkg_rules->{$sub_name};
		} else {
			$sub_name =~ m,^([a-z0-9]*_),i;
			my $sub_prefix = $1 || '';
			if (exists($pkg_rules->{$sub_prefix})) {
				$sub_rules = $pkg_rules->{$sub_prefix};
			} elsif (exists($pkg_rules->{''})) {
				$sub_rules = $pkg_rules->{''};
			}
		}
		next unless (defined($sub_rules));

		foreach my $rule (@$sub_rules) {
			my $generator = 
				$rule->check($pkg_name, $sub_name, @_);
			next unless (defined($generator));
			return($generator);
		}
	}
	return(undef);
}

#sub DESTROY {
#	use Data::Dumper;
#	print STDERR Dumper($_[0]);
#}

1;
