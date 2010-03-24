package Package::Transporter::Package;
use strict;
use warnings;
use Carp qw();
use Scalar::Util qw();

sub ATB_PKG_NAME() { 0 };
sub ATB_VISIT_POINT() { 1 };

sub name { return($_[0][ATB_PKG_NAME]); };

sub set_visit_point {
	$_[0][ATB_VISIT_POINT] = $_[1];
	return;
}

sub transport {
	my ($self, $code_ref) = (shift, shift);

	unless (ref($code_ref) eq 'SCALAR') {
		Carp::confess("Code not a scalar reference.\n");
	}
	my $sa = $@;
	my $rv = $self->[ATB_VISIT_POINT]->($$code_ref, @_);
	if ($@) {
		my $msg = '';
		$msg .= "Offending Code:\n$$code_ref\n" unless($^S);
		$msg .= $@;
		Carp::confess($msg);
	}
	$@ = $sa;
	return($rv);
}

sub create_generator {
	my ($self, $rule) = (shift, shift);

	my $generator;
	if ($rule =~ m,(^|::)([\w_]+($|::))+,) {
		$generator = Package::Transporter::Generator::new_class($rule, $self, @_);
	} else {
		my $code = sprintf(q{
sub($$;@) {
	my($pkg, $sub_name, @args) = @_;
%s
}}, $rule);
		local $@;
		$rule = eval $code;
		Carp::confess($@) if ($@);
		$generator = Package::Transporter::Generator::Anonymous->new($rule);
	}
	return($generator);
}

sub recognize {
	my ($self, $generator) = (shift, shift);

	my $type = ref($generator);
	if ($type eq '') {
		my $prefix = shift // '';
		$generator = $self->create_generator("$prefix$generator");
	} elsif ($type eq 'CODE') {
		$generator = Package::Transporter::Generator::Anonymous
			->new($generator);
	}
	unless (Scalar::Util::blessed($generator) and $generator->can('run')) {
		Carp::confess("The result does not look like a generator.\n");
	}
	return($generator);
}

1;
