package Package::Transporter::Application::Cross_Reference;
use strict;
use warnings;
use Package::Transporter::Application sub{eval shift};

warn('This is unfinished work.'); #FIXME: completely untested
sub cross_reference {
	my ($self, $symbols) = @_;

	my ($create_code, $remove_code) = ('', '');
	foreach my $symbol (@$symbols) {
		my $local_name = $symbol->build_arguments('value');
		$local_name =~ s,^(\W).*::,,;
		my $type = $1;
		$create_code .= sprintf('*%s = %s%s;
', $type, $local_name, $symbol->build_arguments('value'));

		if ($self->is_triggered_undo()) {
			$remove_code .= sprintf('undef %s%s;
', $type, $local_name);
		}
	}

#	print STDERR "cc: ", $create_code, "\n";
	return(\$create_code, \$remove_code);
}


1;
