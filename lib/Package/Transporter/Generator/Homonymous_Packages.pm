package Package::Transporter::Generator::Homonymous_Packages;
use strict;
use warnings;
use Carp qw();
use parent qw(
	Package::Transporter::Generator
	Package::Transporter::Generator::Homonymous
);

my $REMOVE__ = 0;

sub ATB_PKG() { 0 };
sub ATB_BRANCH_INC() { 1 };

sub _init {
	my ($self, $defining_pkg) = (shift, shift);

	if(scalar(@_)) {
		$self->[ATB_BRANCH_INC] = [@_];
	} else {
		$self->[ATB_BRANCH_INC] = [@INC];
	}
	return;
}

# Matching would be expensive.
#sub matcher {...}

sub implement {
	my ($self, $pkg, $sub_name) = (shift, shift, shift);

	my $pkg_file = $self->pkg_file($pkg->name);
	my $fqpf = exists($INC{$pkg_file}) ? $INC{$pkg_file} : '';

	foreach my $directory (@{$self->[ATB_BRANCH_INC]}) {
		my $candidate = "$directory/$pkg_file";
		next if($candidate eq $fqpf);
		next unless (-f $candidate);

		my $copy = $self->match_sub($sub_name, $candidate);
		next unless(defined($copy));
		$copy .= "; return(\\&$sub_name);";
		my $rv = $pkg->transport(\$copy);
		return($rv);
	}
	return($self->failure(undef, $sub_name, "::Homonymous_Package [not in any package of the same name]']"));
}

sub match_sub {
	my ($self, $sub_name, $candidate) = @_;
	$self->read_file($candidate, my $buffer);
	$buffer =~ s,\n__(END|DATA)__.*$,, if($REMOVE__);
	$buffer =~ m,(^|\n)(sub[\s\t]+$sub_name[\s\t]+(\([^\)]*\)[\s\t]*)?\{([^\n]*\}[\s\t]*\n|.*?\n\};?[\s\t]*\n)),sg;
	return($2);
}

1;
