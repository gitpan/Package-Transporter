package Package::Transporter::Generator;
use strict;
use warnings;

sub new {
	my ($class) = (shift);

	my $self = [@_];
	bless($self, $class);
	$self->_init(@_) if ($self->can('_init'));
	Internals::SvREADONLY(@{$self}, 1);

	return($self);
}

sub implement {
	my $self = shift;
	return($self->[0]->(@_));
}

my $std_sub = q{
	sub %s { %s };
	return(\&%s);
};
sub run {
	my ($self, $pkg, $pkg_name, $sub_name) = (shift, shift, shift, shift);

	my $code = $self->implement($pkg, $sub_name, @_);
	return unless (defined($code));
	if (ref($code) eq '') {
		unless ($code =~ m,^[\n\t\s]*sub[\n\t\s],) {
			$code = sprintf($std_sub, $sub_name, $code, $sub_name);
		}
		$code = $pkg->transport(\$code);
	}

	unless (defined($code)) {
		return(failure(ref($self), $sub_name, ' [generator failed]'));
	}
	return($code);
}

my %CLASSES = ();
sub new_class {
	my ($name, $pkg) = @_;

	unless(exists($CLASSES{$name})) {
		my $class;
		if (substr($name, 0, 2) eq '::') {
			$class = "Package::Transporter::Generator$name";
		} else {
			$class = $name;
		}
		# shows the impractical parts of Perl5
		my $class_for_require = $class;
		$class_for_require =~ s,::,/,sg;
		$class_for_require .= '.pm';
		#local $!; # isn't this handled inside require?
		require $class_for_require;
		$CLASSES{$name} = $class;
	}
	return($CLASSES{$name}->new($pkg));
}

sub failure {
	my ($pkg_name, $sub_name, $what) = @_;
	my @where = caller;
	my $failure = sub {
		my @caller = caller();
		my $msg = sprintf(
			q{Undefined subroutine &%s::%s called at %s line %s.},
			$pkg_name || $caller[0],
			$sub_name,
			$caller[1],
			$caller[2])
			."\n"
			.'(Still undefined even after trying AUTOLOAD via Package::Transporter'
			."\n"
			.sprintf(' and finally decided by %s.)', $what || $where[0])
			."\n";
		die($msg);
	};
	return($failure);
}

1;
