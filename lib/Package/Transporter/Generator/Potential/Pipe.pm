package Package::Transporter::Generator::Potential::Pipe;
use strict;
use warnings;
use Carp;
use Data::Dumper;
use POSIX qw(mkfifo);
use parent qw(
	Package::Transporter::Generator
);

sub ATB_PKG() { 0 };
sub ATB_DIRECTORY() { 1 };
sub ATB_CTRL() { 2 };
sub ATB_INFO() { 3 };

sub autoflush($) { my $current = select($_[0]); $| = 1; select($current);}

sub _init {
	my ($self, $pkg, $directory) = (shift, shift, shift);

	$directory //= '.';
	unless(-d $directory) {
		Carp::confess("No such directory '$directory'.");
	}
	my $file_base = sprintf('%s-%s-%s', time, $$, $pkg->name);
	my $file_name = "$directory/$file_base.txt";
	if(-e $file_name) {
		Carp::confess("Output file '$file_name' already exists.");
	}
	open(my $f, '>', $file_name)
	|| Carp::confess("$file_name: open: $!");;
	chmod(oct('0000'), $file_name);
	autoflush($f);

	my $ctrl = "$directory/$file_base.pl";
	mkfifo($ctrl, oct('0000')) 
	|| Carp::confess("$ctrl: mkfifo: '$!'");
	
	$self->[ATB_INFO] = $f;
	$self->[ATB_CTRL] = $ctrl;
	$self->[ATB_DIRECTORY] = $directory;
	return;
}

sub matcher {
	return(sub { 1; });
}

my $separator = "#----------------------------------------------------------------------------\n";
sub implement {
	my ($self, $pkg, $pkg_name, $sub_name) = (shift, shift, shift, shift);

	my $pkg_name = $pkg->name;
	my $info = $self->[ATB_INFO];

	my $content = $separator;
	$content .= "# ".scalar(localtime(time)). "\n";
	$content .= "# The subroutine '$sub_name' is missing in package '$pkg_name'.\n";
	$content .= $separator;
	$content .= Carp::longmess;
	$content .= $separator;
	$content .= Dumper(\@_);
	$content .= $separator;

	chmod(oct('0644'), $info)
	|| Carp::confess("$info: chmod: $!");	
	print $info $content
	|| Carp::confess("$info: print: $!");

	while(1) {
		chmod(oct('0660'), $self->[ATB_CTRL]);
		open(my $ctrl, '<', $self->[ATB_CTRL])
		|| Carp::confess($self->[ATB_CTRL].": open: $!");
		my $read = read($ctrl, my $code, 2**16);
		close($ctrl);
		chmod(oct('0000'), $self->[ATB_CTRL]);

		local $@;
		my $sub_ref = eval { $pkg->transport(\$code); };
		if($@) {
			my $content = "# Ooops, the following error ocurred.\n";
			$content .= "$@\n";
			print $info $content;
		} else {
			return($sub_ref) if(ref($sub_ref) eq 'CODE');
			my $existing = "$pkg_name\::$sub_name";
			return(\&$existing) if(defined(&$existing));
			print $info "# What you entered did not result in the missing subroutine, neither did it return a subroutine reference.\n";
		}
		print $info $separator;
	}
}

sub DESTROY {
	close($_[0][ATB_INFO]) if (defined($_[0][ATB_INFO]));
	unlink($_[0][ATB_CTRL]) if (defined($_[0][ATB_CTRL]));
}

1;
