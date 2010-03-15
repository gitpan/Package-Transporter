package Package::Transporter::Generator::Require_Customized;
use strict;
use warnings;
use parent qw(
	Package::Transporter::Generator
);

sub ATB_PKG() { 0 };
sub ATB_DATA() { 1 };

sub _init {
	my ($self) = (shift);

	$self->[ATB_PKG] = shift;
	$self->[ATB_DATA] = {@_};
	return;
}

sub search_inc_for($) {
        my $file_name = shift;

	$file_name =~ s,[\000-\037],X,sg;
        if (substr($file_name, 0, 1) eq '/') {
                return($file_name);
        } elsif (substr($file_name, 0, 2) eq '::') {
                my $fqfn = (caller())[1];
                $fqfn =~ s,/[^/]+$,/,sg;
                $fqfn .= substr($file_name, 2);
		return($fqfn);
        } else {
                foreach my $directory (@INC) {
                        my $fqfn = "$directory/$file_name";
                        next unless (-f $fqfn);
                        return($fqfn);
                }
        }
}

my $longest_first = sub { length($b) <=> length($a) };
sub implement {
	my ($self, $pkg, $sub_name) = (shift, shift, shift);

	unless($sub_name eq 'require_customized') {
		return(Package::Transporter::Generator::failure(undef, $sub_name, ' [the name require_customized is hardcoded]'));
	}
	my $file_name = search_inc_for($_[0]);
	unless(defined($file_name)) {
		return(Package::Transporter::Generator::failure(undef, $sub_name, q{ [file '$file_name' not found]}));
	}

	read_file($file_name, my $code);
	if(scalar(%{$self->[ATB_DATA]})) {
		my $data_re = 
			'__('
			.join('|', sort $longest_first
				keys(%{$self->[ATB_DATA]}))
			.')__';
		$code =~ s,$data_re,$self->[ATB_DATA]{$1},sg;
	}
	return($pkg->transport(\$code));
}

sub read_file {
        open(F, '<', $_[0]) || Carp::confess("$_[0]: open/r: $!\n");
        read(F, $_[1], (stat(F))[7]) || Carp::confess("$_[0]: read: $!\n");
        close(F);
        return;
}

1;
