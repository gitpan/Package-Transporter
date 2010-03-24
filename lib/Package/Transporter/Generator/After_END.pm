package Package::Transporter::Generator::After_END;
use strict;
use warnings;
use Carp qw();
use parent qw(
	Package::Transporter::Generator
	Package::Transporter::Generator::Homonymous
);

sub ATB_PKG() { 0 };
sub ATB_FILE_NAME() { 1 };

sub _init {
	my ($self, $defining_pkg) = (shift, shift);

#	$self->[ATB_FILE_NAME] = (caller)[1];
}

sub matcher {
	my ($self) = (shift);

	$self->read_file($self->[ATB_FILE_NAME], my $buffer);
	$buffer =~ s,^.*?\n__END__,,;
	my @names = ($buffer =~ m,(?:^|\n)sub[\s\t]+(\w+)[\s\t]+(?:\([^\)]*\)[\s\t]*)?\{(?:[^\n]*\}|.*?\n\}),sg);

	return(sub { scalar(grep($_ eq $_[1], @names)) > 0 });
}

sub implement {
	my ($self, $pkg, $sub_name) = (shift, shift, shift);

	my $copy = $self->match_sub($sub_name, $self->[ATB_FILE_NAME], 0);
	unless(defined($copy)) {
		return($self->failure(undef, $sub_name, "::Homonymous_Copy_n_Paste [not in myself]']"));
	}
	$copy .= "; return(\\&$sub_name);";
	my $rv = $pkg->transport(\$copy);
	return($rv);
}

sub match_sub {
	my ($self, $sub_name, $candidate) = (shift, shift, shift);

	$self->read_file($candidate, my $buffer);
	$buffer =~ s,^.*?\n__END__,,;
	$buffer =~ m,(?:^|\n)(sub[\s\t]+$sub_name[\s\t]+(\([^\)]*\)[\s\t]*)?\{(?:[^\n]*\}|.*?\n\})),sg;
	return($1);
}

1;
