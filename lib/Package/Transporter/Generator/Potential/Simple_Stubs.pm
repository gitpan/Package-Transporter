package Package::Transporter::Generator::Potential::Simple_Stubs;
use strict;
use warnings;
use parent qw(
	Package::Transporter::Generator
);

sub ATB_PKG() { 0 };
sub ATB_STUBS_FILE() { 1 };
sub ATB_SUB_STUBS() { 2 };

sub _init {
	my ($self) = (shift);

	read_file($self->[ATB_STUBS_FILE], my $buffer);
	my %sub_stubs = ();
	foreach my $line (split(/\n+/, $buffer)) {
		next if ($line =~ m,^[\s\t]*\#,);
		chomp($line);
		my ($key, $value) = split(/\t+/, $line);
#		my ($key, $value) = ($line =~ m,^(.*)\t+(.*)$,);
		$value = '' unless (defined($value));
		$sub_stubs{$key} = $value;
	}

	$self->[ATB_SUB_STUBS] = \%sub_stubs;
	return;
}

sub matcher {
	my ($self) = (shift);

	return(sub {
		return(exists($self->[ATB_SUB_STUBS]->{'*'}) ||
			exists($self->[ATB_SUB_STUBS]->{$_[1]}));
	});
}

sub implement {
	my ($self, $pkg, $pkg_name, $sub_name) = (shift, shift, shift, shift);

	my $sub_stubs = $self->[ATB_SUB_STUBS];
	my $rv;
	unless (exists($sub_stubs->{$sub_name})) {
		unless (exists($sub_stubs->{'*'})) {
			return($self->failure(undef, $sub_name, "::Homonymous_Tie [not in '$self->[ATB_STUBS_FILE]']"));
		} else {
			$rv = $sub_stubs->{'*'};
		}
	} else {
		$rv = $sub_stubs->{$sub_name};
	}

	my $pkg_name = $pkg->name;
	print STDERR "Creating simple stub 'sub $sub_name { return($rv);}' in package '$pkg_name'.\n";
	return(sprintf('return(%s)', $rv));
}

sub read_file {
        open(F, '<', $_[0]) || Carp::confess("$_[0]: open/r: $!\n");
        read(F, $_[1], (stat(F))[7]) || Carp::confess("$_[0]: read: $!\n");
        close(F);
        return;
}

1;
