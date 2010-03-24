package Package::Transporter::Generator::Fatal;
use strict;
use warnings;
BEGIN { require Fatal; };
use parent qw(
	Package::Transporter::Generator
);

sub ATB_PKG() { 0 };
sub ATB_DST_PKG() { 1 };
my $prefix = 'fatal_';

sub implement {
	my ($self, $pkg, $sub_name) = (shift, shift, shift);

	unless($sub_name =~ s,^$prefix,,) {
		return($self->failure(undef, $sub_name, "::Fatal ['$sub_name' not matching '$prefix(\\w+)']"));

	}

	my $sub_proto;
	my $is_core = 0;
	if (exists(&$sub_name)) {
		$sub_proto = prototype(\&$sub_name);
	} else {
		$sub_proto = prototype("CORE::$sub_name");
		$is_core = 1;
	}
	my $definition = (defined($sub_proto) ? " ($sub_proto)" : '');
	my @protos = Fatal::fill_protos($sub_proto);
	my $code = sprintf(q{
sub fatal_%s%s {
	local($", $!) = (', ', 0);
%s
};
return(\&fatal_%s);},
		$sub_name,
		$definition,
		Fatal::write_invocation($is_core, $sub_name, $sub_name, 1, @protos),
		$sub_name
	);
	return($pkg->transport(\$code));
}

sub matcher {
	return(sub { return(substr($_[2], 0, 6) eq $prefix); }); 
}

1;
