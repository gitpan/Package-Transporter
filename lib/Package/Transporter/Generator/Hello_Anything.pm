package Package::Transporter::Generator::Hello_Anything;
use strict;
use warnings;
use parent qw(
	Package::Transporter::Generator
);

sub implement {
	my ($self, $pkg, $sub_name) = (shift, shift, shift);

	my $sub_body = sprintf(
		qq{print 'Hello %s\n'},
		substr($sub_name, 6) || '');
	return($sub_body);
}

1;