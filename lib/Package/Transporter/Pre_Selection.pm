package Package::Transporter::Pre_Selection;
use strict;
use warnings;
use Carp qw();
use Scalar::Util;

sub new { bless({}, __PACKAGE__); }

sub register_rules {
	my ($self, $rule, $pkg_name, $sub_name) = @_;

	my ($pkg_names, $sub_names);
	if (ref($pkg_name) eq 'ARRAY') {
		$pkg_names = $pkg_name
	} else {
		$pkg_names = [$pkg_name];
	}
	if (ref($sub_name) eq 'ARRAY') {
		$sub_names = $sub_name
	} else {
		$sub_names = [$sub_name];
	}
	foreach my $pkg_name (@$pkg_names) {
		foreach my $sub_name (@$sub_names) {
			$self->register_rule($rule, $pkg_name, $sub_name);
		}
	}
}

my $pkg_re = '^(|\w+|>>|(\w+::)*(\w+(::|>>|<<|<>|\|\|)))$';
sub register_rule {
	my ($self, $rule, $pkg_name, $sub_name) = @_;

	if ($pkg_name !~ m,$pkg_re,so) {
		Carp::confess("Package name '$pkg_name' is not valid.\n");
	}
	unless ($sub_name =~ m,^\w*$,) {
		Carp::confess("Subroutine name '$sub_name' is not valid.\n");
	}

	$self->{$pkg_name} = {} unless (exists($self->{$pkg_name}));
	my $pkg_rules = $self->{$pkg_name};
	$pkg_rules->{$sub_name} = [] unless (exists($pkg_rules->{$sub_name}));
	my $sub_rules = $pkg_rules->{$sub_name};

	push(@$sub_rules, $rule);
	return;
}

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
