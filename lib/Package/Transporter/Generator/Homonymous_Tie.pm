package Package::Transporter::Generator::Homonymous_Tie;
use strict;
use warnings;
use GDBM_File;
use Fcntl;
use parent qw(
	Package::Transporter::Generator
	Package::Transporter::Generator::Homonymous
);

sub ATB_PKG() { 0 };
sub ATB_DB_FILE() { 1 };
sub ATB_SUB_BODIES() { 2 };

sub _init {
	my ($self, $defining_pkg) = (shift, shift);

	my $file_name = $self->pkg_file($defining_pkg->name);
	$file_name =~ s,\.pm$,.dbm,si;
	tie(my %sub_bodies, 'GDBM_File', $file_name, O_RDONLY, 0);

	$self->[ATB_DB_FILE] = $file_name;
	$self->[ATB_SUB_BODIES] = \%sub_bodies;
	if($^C == 1) {
		my @keys = grep($_ !~ m/^(\w+)-prototype$/,
			keys(%{$self->[ATB_SUB_BODIES]}));
		my $code = $self->assemble(@keys);
		$self->[ATB_PKG]->transport(\$code);
	}

	return;
}

sub prototypes {
	my ($self) = (shift);

	my $code = '';
	foreach my $key (keys(%{$self->[ATB_SUB_BODIES]})) {
		next unless ($key =~ m,^(\w+)-prototype$,);
		$code .= sprintf('sub %s(%s); ',
			$1, $self->[ATB_SUB_BODIES]->{$key});
	}
	$self->[ATB_PKG]->transport(\$code);
}

sub matcher {
	my ($self) = (shift);

	return(sub {
		return(exists($self->[ATB_SUB_BODIES]->{$_[1]}));
	});
}

sub implement {
	my ($self, $pkg, $sub_name) = (shift, shift, shift);

	unless (exists($self->[ATB_SUB_BODIES]->{$sub_name})) {
		return($self->failure(undef, $sub_name, "::Homonymous_Tie [not in '$self->[ATB_DB_FILE]']"));
	}
	my $code = $self->assemble($sub_name);
	return($pkg->transport(\$code));
}

my $std_sub = q{
	sub %s%s {
%s
	};
	return(\&%s);
};
sub assemble {
	my ($self) = (shift);

	my $code = '';
	my $sub_bodies = $self->[ATB_SUB_BODIES];
	foreach my $sub_name (@_) {
		my $prototype = '';
		if (exists($sub_bodies->{"$sub_name-prototype"})) {
			$prototype = '('.$sub_bodies->{"$sub_name-prototype"}.')';
		}

		$code .= sprintf($std_sub, 
			$sub_name,
			$prototype,
			$sub_bodies->{$sub_name},
			$sub_name);
	}
	return($code);
}

1;
