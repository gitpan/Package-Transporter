package Package::Transporter::Generator::Auto_Autoload;
use strict;
use warnings;
use Scalar::Util qw();
use parent qw(
	Package::Transporter::Generator
);
our $VERBOSE = 1;

sub ATB_PKG() { 0 };
sub ATB_PACKAGES() { 1 };

sub read_file_contents($$) {
        open(F, '<', $_[0]) || Carp::confess("$_[0]: open/r: $!\n");
        read(F, $_[1], (stat(F))[7]) || Carp::confess("$_[0]: read: $!\n");
        close(F);
        return;
}

unshift(@INC, \&Package::Transporter::Generator::Auto_Autoload::INC);

my %PACKAGES = ();
sub Package::Transporter::Generator::Auto_Autoload::INC {
	my ($self, $file_name) = @_;

	my $pkg_name = $file_name;
	$pkg_name =~ s,/,::,sg;
	$pkg_name =~ s,\.pm$,,sg;
	return unless(exists($PACKAGES{$pkg_name}));

	my $buffer;
	foreach my $path (@INC) {
		my $fqfn = "$path/$file_name";
		next unless (-f $fqfn);
		read_file_contents($fqfn, $buffer);
		$INC{$file_name} = $fqfn;
	}
#		print STDERR "fn: $buffer\n";
	return unless(defined($buffer));

	my $pkg_content = '';
	$buffer =~ s/\n__(END|DATA)__.*$//s;
	while ($buffer =~ s/(.*?)(?:^|\n)(sub[\s\t]+(\w+)[\s\t]+(?:\([^\)]*\)[\s\t]*)?\{(?:[^\n]*\}[\s\t]*\n|.*?\n\};?[\s\t]*\n))//s) {
#		print STDERR "fn: $2\n";
		$pkg_content .= $1;
		$PACKAGES{$pkg_name}{$3} = $2 . "; return(\\&$3);";
	}
	$pkg_content .= $buffer;
	$pkg_content .= <<'EOP';
use Package::Transporter;
Package::Transporter->new(sub{eval shift});
1;
EOP
	my @lines = split(/\n/, $pkg_content);

#		use Data::Dumper;
#		print STDERR Dumper(\@lines, \%PACKAGES);

	my $reader = sub { $_ = shift(@lines); return(scalar(@lines) > 0); };
	return($reader);
}

sub _init {
	my ($self) = (shift);

	my @packages = splice(@$self, 1);
	foreach (@packages) {
		$PACKAGES{$_} = {};
	}

	return;
}

sub matcher {
	my ($self) = (shift);

	my $matcher = sub {
		return (exists($PACKAGES{$_[0]})
			and exists($PACKAGES{$_[0]}{$_[1]}));
	};
	return($matcher);
}

sub implement {
	my ($self, $pkg, $sub_name) = (shift, shift, shift);

	my $pkg_name = $pkg->name;
	unless(exists($PACKAGES{$pkg_name})) {
		return($self->failure(undef, $sub_name, '::Auto_Autoload [package not configured]'));
	}
	my $parsed = $PACKAGES{$pkg_name};
	unless(exists($parsed->{$sub_name})) {
		return($self->failure(undef, $sub_name, '::Auto_Autoload [sub not seen, yet]'));
	}
	
	return($pkg->transport(\$parsed->{$sub_name}));
}

1;
