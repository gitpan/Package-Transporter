package Package::Transporter::Application::Symbol_Table;
use strict;
use warnings;
use Package::Transporter::Application sub{eval shift};

warn('This is unfinished work.'); #FIXME: completely untested
sub symbol_table {
	my ($self, $symbols) = @_;

	my ($create_code, $remove_code) = ('', '');
	foreach my $symbol (@$symbols) {
		my $local_name = $symbol->build_arguments('value');
		$local_name =~ s,^(\W).*::,,;
		my $type = $1;
		$create_code .= sprintf('*%s = &%s;
', $local_name, $symbol->build_arguments('value'));

		if ($self->is_triggered_undo()) {
			$remove_code .= sprintf('undef %s%s;
', $type, $local_name);
		}
	}

#	print STDERR "cc: ", $create_code, "\n";
	return(\$create_code, \$remove_code);
}


1;