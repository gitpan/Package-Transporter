package Package::Transporter::Application::Constant_Function;
use strict;
use warnings;
use Package::Transporter::Application sub{eval shift};


sub constant_function {
	my ($self, $symbols) = @_;

	my ($create_code, $remove_code) = ('', '');
	foreach my $symbol (@$symbols) {
		$create_code .= sprintf('sub %s { %s };
', $symbol->build_arguments('name', 'representation'));

		if ($self->is_triggered_undo()) {
			$remove_code .= sprintf('undef &%s;
', $symbol->build_arguments('name'));
		}
	}

	return(\$create_code, \$remove_code);
}


1;