package Package::Transporter::Hierarchy::Drain;
use strict;
use warnings;
#use Carp qw();
use Scalar::Util;
use parent qw(
	Package::Transporter::Hierarchy
);

sub collect_generators {
	my ($self, $pkg_list, $pkg_family, $pkg_name) = @_;

	my @pkg_prefixes = ('>>');
	foreach my $pkg_prefix (reverse(@$pkg_family)) {
		next if ($pkg_prefix eq $pkg_name);
		push(@pkg_prefixes, "$pkg_prefix||");
	}
	foreach my $pkg_prefix (reverse(@$pkg_list)) {
		next if ($pkg_prefix eq $pkg_name);
		next if ($pkg_prefix eq '');
		my $pkg_prefix_copy = $pkg_prefix;
		unless ($pkg_prefix_copy =~ s,::$,>>,) {
			$pkg_prefix_copy .= '>>';
		}
		push(@pkg_prefixes, $pkg_prefix_copy);
	}
	push(@pkg_prefixes, "$pkg_name<<", "$pkg_name<>", "$pkg_name||");

	my %generators = ();
	foreach my $pkg_prefix (@pkg_prefixes) {
		next unless (exists($self->{$pkg_prefix}));
		my $branch_in = $self->{$pkg_prefix};
		foreach my $key (keys(%$branch_in)) {
			unless (exists($generators{$key})) {
				$generators{$key} = {};
			}
			my $branch_out = $generators{$key};
			foreach my $generator (@{$branch_in->{$key}}) {
				my $type = Scalar::Util::blessed($generator);
				unless (exists($branch_out->{$type})) {
					$branch_out->{$type} = [];
				}
				push(@{$branch_out->{$type}}, $generator);
#				last;
			}
		}
	}

	return(\%generators);
}

sub release {
	my ($self, $pkg_name) = @_;

	CORE::delete($self->{"$pkg_name<<"});

	if (exists($self->{"$pkg_name<>"})) {
		my $renamed = delete($self->{"$pkg_name<>"});
		unless (exists($self->{"$pkg_name>>"})) {
			$self->{"$pkg_name>>"} = $renamed;
		} else {
			my $branch = $self->{"$pkg_name>>"};
			foreach my $key (keys(%$renamed)) {
				unless (exists($branch->{$key})) {
					$branch->{$key} = [];
				}
				push(@{$branch->{$key}}, @{$renamed->{$key}});
			}
		}
	}
	return;
}

#sub DESTROY {
#	use Data::Dumper;
#	print STDERR Dumper($_[0]);
#}

1;
