package Package::Transporter::Generator::Eponymous_Packages;
use strict;
use warnings;
use Carp qw();
use parent qw(
	Package::Transporter::Generator
);

my $REMOVE__ = 0;

sub ATB_PKG() { 0 };
sub ATB_BRANCH_INC() { 1 };

my %DIRECTORIES = ();
sub pkg_file($) {
	my ($self, $pkg_name) = (shift, shift);

	if (exists($DIRECTORIES{$pkg_name})) {
		return($DIRECTORIES{$pkg_name});
	}
	my $pkg_file = $pkg_name;
	$pkg_file =~ s,::,/,sg;
	$pkg_file .= '.pm';

	my $file_name = $INC{$pkg_file} || $pkg_file;

	$DIRECTORIES{$pkg_name} = $file_name;
	return($file_name);
}

sub _init {
	my ($self, $defining_pkg) = (shift, shift);

	if(scalar(@_)) {
		$self->[ATB_BRANCH_INC] = [@_];
	} else {
		$self->[ATB_BRANCH_INC] = [@INC];
	}
	return;
}

#sub matcher {
#	my ($self) = (shift);
#	return(sub {
#		return(exists($self->[ATB_SUB_BODIES]->{$_[1]}));
#	});
#}

sub implement {
	my ($self, $pkg, $sub_name) = (shift, shift, shift);

	my $pkg_file = $self->pkg_file($pkg->name);

	foreach my $directory (@{$self->[ATB_BRANCH_INC]}) {
		my $candidate = "$directory/$pkg_file";
		if(-f $candidate) {
			my $copy = $self->match_sub($sub_name, $candidate);
			next unless(defined($copy));
			$copy .= "; return(\\&$sub_name);";
			my $rv = $pkg->transport(\$copy);
			return($rv);
		}
	}
	return($self->failure(undef, $sub_name, "::Eponymous_Package [not in any package of the same name]']"));
}

sub match_sub {
	my ($self, $sub_name, $candidate) = (shift, shift, shift);
	read_file($candidate, my $buffer);
	$buffer =~ s,\n__(END|DATA)__.*$,, if($REMOVE__);
	return unless($buffer =~ m,(^|\n)(sub[\s\t]+$sub_name[\s\t]+(\([^\)]*\)[\s\t]*)?\{([^\n]*\}[\s\t]*\n|.*?\n\};?[\s\t]*\n)),sg);
	return($2);
}

sub read_file {
        open(F, '<', $_[0]) || Carp::confess("$_[0]: open/r: $!\n");
        read(F, $_[1], (stat(F))[7]) || Carp::confess("$_[0]: read: $!\n");
        close(F);
        return;
}

1;
