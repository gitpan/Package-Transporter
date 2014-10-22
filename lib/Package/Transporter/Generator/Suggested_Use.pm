package Package::Transporter::Generator::Suggested_Use;
use strict;
use warnings;
use Scalar::Util qw();
use Package::Transporter::Generator::Suggested_Use::Suggestions;
use parent qw(
	Package::Transporter::Generator
);
our $VERBOSE = 1;

sub ATB_PKG() { 0 };
sub ATB_SUGGESTSIONS() { 1 };

sub _init {
	my ($self) = (shift);

	unless (defined($self->[ATB_SUGGESTSIONS])) {
		$self->[ATB_SUGGESTSIONS] =
			Package::Transporter::Generator::Suggested_Use::Suggestions->new();
	}
	return;
}

sub matcher {
	my ($self) = (shift);

	return(sub {
		my $ref = Scalar::Util::blessed($_[2]) ? 'OBJECT' : ref($_[2]);
		return (defined($self->[ATB_SUGGESTSIONS]->lookup($_[1], $ref, scalar(@_)-2)));

	});
}

sub implement {
	my ($self, $pkg, $sub_name) = (shift, shift, shift);

	my $ref = Scalar::Util::blessed($_[0]) ? 'OBJECT' : ref($_[0]);
	my $suggested = $self->[ATB_SUGGESTSIONS]->lookup($sub_name, $ref, scalar(@_));

	unless (defined($suggested)) {
		return($self->failure(undef, $sub_name, '::Suggested_Use [no suggestion found]'));
	}
	my ($load, $module) = @$suggested;
	
	my $sub_text;
	if ($load eq 'use') {
		$sub_text = sprintf(q{
my ($self, $verbose) = (shift(@_), shift(@_));
print STDERR qq{Loading suggested module '%s' to enable subroutine '%s'.\n} if ($verbose);
use %s;
return(\&%s) if (defined(&%s));
return(\&%s::%s) if (defined(&%s::%s));
return($self->failure(undef, '%s', q{::Suggested_Use ['use %s' had not the required effect]}));
		},
			$module, $sub_name,
			$module,
			$sub_name, $sub_name, 
			$module, $sub_name, $module, $sub_name,
			$sub_name, $module);
	} elsif ($load eq 'parent') {
		$sub_text = sprintf(q{
my ($self, $verbose) = (shift(@_), shift(@_));
print STDERR qq{Loading suggested parent '%s' to enable method '%s'.\n} if ($verbose);
use parent qw(%s);
my $can = UNIVERSAL::can($_[0], '%s');
return($can) if (defined($can));
return($self->failure(undef, '%s', q{::Suggested_Use ['use parent qw(%s)' had not the required effect]}));
		},
			$module, $sub_name,
			$module,
			$sub_name,
			$sub_name, $module);
	} else {
		return($self->failure(undef, $sub_name, "::Suggested_Use [invalid loading '$load']"));
	}

	return($pkg->transport(\$sub_text, $self, $VERBOSE, $_[0]));
}

1;
