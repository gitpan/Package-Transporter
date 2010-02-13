package Package::Transporter::Application::Include_File;
use strict;
use warnings;
use Package::Transporter::Application sub{eval shift};


sub read_file {
        open(F, '<', $_[0]) || Carp::confess("$_[0]: open/r: $!\n");
        read(F, $_[1], (stat(F))[7]) || Carp::confess("$_[0]: read: $!\n");
        close(F);
        return;
}


my $longest_first = sub { length($b) <=> length($a) };

sub include_file {
	my ($self, $symbols) = @_;

	my $file_name = $self->[ATB_DATA];

	my $create_code = undef;
	if (substr($file_name, 0, 1) eq '/') {
		read_file($file_name, $create_code);
	} elsif (substr($file_name, 0, 2) eq '::') {
		my $fqfn = (caller())[1];
		$fqfn =~ s,/[^/]+$,/,sg;
		$fqfn .= substr($file_name, 2);
		read_file($fqfn, $create_code);
	} else {
		foreach my $directory (@INC) {
			my $fqfn = "$directory/$file_name";
			next unless (-f $fqfn);
			read_file($fqfn, $create_code);
			last;
		}
	}
	unless (defined($create_code)) {
		Carp::confess("Could not find file name '$file_name' in \@INC.");
	}

	my @names = ();
	my %symbols = ();
	foreach my $symbol (@$symbols) {
		my $name = $symbol->get_name();
		push(@names, $name);
		$symbols{$name} = $symbol;
	}
	@names = sort $longest_first @names;

	my $symbol_re = "(". join('|', @names) .')';
	$create_code =~ s/__${symbol_re}__/$symbols{$1}->get_representation()/sge;

	return(\$create_code, undef);
}


1;
