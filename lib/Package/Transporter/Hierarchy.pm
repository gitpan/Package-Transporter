package Package::Transporter::Hierarchy;
use strict;
use warnings;
use Carp qw();

sub new { bless({}, $_[0]); }

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

1;
