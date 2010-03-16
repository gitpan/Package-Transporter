package Package::Transporter::Generator::Argument_in_Name;
use strict;
use warnings;
use parent qw(
	Package::Transporter::Generator
);

sub ATB_PKG() { 0 };
sub ATB_RE() { 1 };
sub ATB_OFFSET() { 2 };

sub _init {
	my ($self) = (shift);

	$self->[ATB_RE] //= '_(\w+)$';
	$self->[ATB_OFFSET] //= 0;
	return;
}

sub implement {
	my ($self, $pkg, $sub_name) = (shift, shift, shift);

	my $defining_pkg = $self->[ATB_PKG]->name;
	my $sub_base = $sub_name;
	unless($sub_base =~ s/$self->[ATB_RE]//s) {
		return($self->failure(undef, $sub_name, "::Argument_in_Name [RE '$self->[ATB_RE]' did not match]"));

	}
	my $argument = $1;

	my @a = ();
	for (my $i = 0; $i < $self->[ATB_OFFSET]; $i++) {
		push(@a, "\$_[$i]");
	}
	push(@a, $argument);
	push(@a, "\@_[$#a..\$#_]");
	my $argument_list = join(', ', @a);

	my $sub_text = sprintf(q{
sub %s { return(%s::%s(%s)); };
return(\&%s);
		}, 
		$sub_name,
		$defining_pkg, $sub_base,
		$argument_list,
		$sub_name);
	
	return($pkg->transport(\$sub_text));
}

1;
