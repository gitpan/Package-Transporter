package Package::Transporter::Generator::Potential::Homonymous_Directory;
use strict;
use warnings;
use parent qw(
	Package::Transporter::Generator
	Package::Transporter::Generator::Potential::Homonymous
);

sub ATB_PKG() { 0 };
sub ATB_BASE_DIR() { 1 };

sub _init {
	my ($self, $defining_pkg) = (shift, shift);

	my $base_dir = $self->pkg_file($defining_pkg->name);
	$base_dir =~ s,\.pm$,,si;
	
	unless (-e $base_dir) {
		Carp::confess("Can't load from directory '$base_dir' - does not exist.");
	}
	unless (-d $base_dir) {
		Carp::confess("Can't load from directory '$base_dir' - not a directory.");
	}
	$self->[ATB_BASE_DIR] = $base_dir;

	if($^C == 1) {
		opendir(D, $base_dir)
		|| Carp::confess("$base_dir: opendir: $!");
		my @names = readdir(D)
		|| Carp::confess("$base_dir: readdir: $!");
		closedir(D)
		|| Carp::confess("$base_dir: closedir: $!");

		my @file_names = map("$self->[ATB_BASE_DIR]/$_",
			grep($_ =~ m/\.pl$/, @names));
		my $code = 'foreach my $pkg (@{$_[0]}) { require $pkg; };';
		return($defining_pkg->transport(\$code, \@file_names));
	}
	return;
}

sub prototypes {
	my ($self) = (shift);

	my $file_name = $self->[ATB_BASE_DIR] . '/-prototypes.pl';
	my $code = "require shift(\@_);";
	$self->[ATB_PKG]->transport(\$code, $file_name);
}

sub matcher {
	my ($self) = (shift);

	opendir(D, $self->[ATB_BASE_DIR]);
	my %pl_files = ();
	foreach my $file_name (readdir(D)) {
		next unless ($file_name =~ m/^(\w+)\.pl$/i, );
		$pl_files{$1} = 1;
	}
	closedir(D);

	return(sub {
		return(exists($pl_files{$_[1]}));
	});
}

sub implement {
	my ($self, $pkg, $pkg_name, $sub_name) = (shift, shift, shift, shift);

	my $file_name = "$self->[ATB_BASE_DIR]/$sub_name.pl";
	my $code = "require shift(\@_); return(\\&$sub_name);";
	return($pkg->transport(\$code, $file_name));
}

1;
