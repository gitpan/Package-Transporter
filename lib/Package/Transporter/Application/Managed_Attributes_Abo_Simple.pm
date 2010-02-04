package Package::Transporter::Application::Managed_Attributes_Abo_Simple;
use strict;
use warnings;
use Package::Transporter::Application sub{eval shift};

sub managed_attributes_abo_simple {
	my ($self, $symbols) = @_;

	my ($create_code, $remove_code) = ('', '');
	foreach my $symbol (@$symbols) {
		$create_code .= sprintf('
sub set_%s { $_[0][%s] = $_[1]; return; };
sub get_%s { return($_[0][%s]); };
', $symbol->build_arguments('name_short', 'name', 'name_short', 'name'));

		if ($self->is_triggered_undo()) {
			$remove_code .= sprintf('
undef &set_%s;
undef &get_%s;
', $symbol->build_arguments('name_short', 'name_short'));
		}
	}

	return(\$create_code, \$remove_code);
}


1;