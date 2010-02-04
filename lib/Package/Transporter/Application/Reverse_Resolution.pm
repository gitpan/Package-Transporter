package Package::Transporter::Application::Reverse_Resolution;
use strict;
use warnings;
use Package::Transporter::Application sub{eval shift};

warn('This is unfinished work.'); #FIXME: $RR is not declared
sub reverse_resolution {
	my ($self, $symbols) = @_;

	my ($create_code, $remove_code) = ('', '');
	foreach my $symbol (@$symbols) {
		$create_code .= sprintf('$RR{%s}{%s} = %s;
', $self->[ATB_DATA], $symbol->build_arguments('representation', 'name'));

		if ($self->is_triggered_undo()) {
				$remove_code .= sprintf('delete($RR{%s}{%s});
', $self->[ATB_DATA], $symbol->build_arguments('representation'));
		}
	}

	return(\$create_code, \$remove_code);
}


1;