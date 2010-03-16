package Package::Transporter::Generator::Interactive;
use strict;
use warnings;
use Carp;
use Data::Dumper;
use parent qw(
	Package::Transporter::Generator
);

sub matcher {
	return(sub { 1; });
}

sub implement {
	my ($self, $pkg, $sub_name) = (shift, shift, shift);

	my $pkg_name = $pkg->name;
	print STDERR "#----------------------------------------------------------------------------\n";
	print STDERR "# The subroutine '$sub_name' is missing in package '$pkg_name'.\n";
	print STDERR "# You can write it now if you're adventurous.\n";
	while(1) {
		print STDERR "# Menu: [1:Help] [2:Alias] [3:transport] [4:cluck] [5:Dumper(\@_)] [6:Give up]\n";
		print STDERR "# Please enter 1-6 followed by Enter: ";
		my $what = <STDIN>;
		next unless(defined($what));
		$what =~ s,\D+,,sg;
		if($what == 1) {
			print STDERR <<'EOH'
# 
# 1: Display this text.
# 2: Meant for fixing typing mistakes. Enter the real subroutine name.
# 3: Paste the $code to be passed to $self->transport(\$code)
# 4: Execute Carp::cluck to see where the request is coming from.
# 5: Print the arguments with Data::Dumper(\@_);
# 6: Indicate failure and eventually die().
# 
# For further details see Package::Transporter::Generator::Interactive
EOH
		} elsif($what == 2) {
			print STDERR "# Enter the name of an existing subroutine:\n";
			my $name = <STDIN>;
			chomp($name);
			unless($name =~ m,^(\w+($|::))+$,) {
				print STDERR "# Error: doesn't look like a (fully qualified) subroutine name.\n";
			} else {
				my $existing = 
					(($name =~ m,:,) ? '' : "$pkg_name\::")
					. $name;
				if(defined(&$existing)) {
					my $code = "*$sub_name = \\&$name;";
					my $sub_ref = $pkg->transport(\$code);
					return(\&$existing);
				}
				print STDERR "# Error: the name you gave does not exist.\n";
			}
			
		} elsif($what == 3) {
			print STDERR "# Enter Perl code and press Ctrl-D on an empty line when done.\n";
			print STDERR "# Mistakes might have fatal consequences.\n";
			my $read = read(STDIN, my $code, 2**16);
			local $@;
			my $sub_ref = eval { $pkg->transport(\$code); };
			if($@) {
				print STDERR "# Ooops, the following error ocurred.\n";
				print STDERR "$@\n";
			} else {
				return($sub_ref) if(ref($sub_ref) eq 'CODE');
				my $existing = "$pkg_name\::$sub_name";
				return(\&$existing) if(defined(&$existing));
				print STDERR "# What you entered did not result in the missing subroutine, neither did it return a subroutine reference.\n";
			}
		} elsif($what == 4) {
			Carp::cluck;
		} elsif($what == 5) {
			print STDERR Dumper(\@_);
		} elsif($what == 6) {
			return($self->failure(undef, $sub_name, "::Interactive [requested by interactive programmer]']"));
		} else {
			print STDERR "'$what' is not one of the expected numbers. Try again.\n";
		}
		print STDERR "#----------------------------------------------------------------------------\n";
	}
}

1;
