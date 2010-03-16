package Package::Transporter::Generator::Get_Set_Methods;
use strict;
use warnings;
use Scalar::Util;
use parent qw(
	Package::Transporter::Generator
);

sub implement {
	my ($self, $pkg, $sub_name) = (shift, shift, shift);

	$sub_name =~ m/^(g|s)et_(\w+)$/s;
	my ($what, $name) = ($1, $2);
	my $NAME = uc($name);
	my $key = $pkg->name. '::ATB_' . $NAME;
	unless(defined(&$key)) {
		return(Package::Transporter::Generator::failure(undef, $sub_name, "::Get_Set_Methods [missing constant function ATB_$NAME]"));
	}

	my $type = Scalar::Util::reftype($_[0]);
	my $attribute;
	if($type eq 'ARRAY') {
		$attribute = "[ATB_$NAME]";
	} elsif($type eq 'HASH') {
		$attribute = "{+ATB_$NAME}";
#	} elsif($type eq 'SCALAR') { # has one single attribute...
#		$attribute = '${$_[0]}';
#	} elsif($type eq 'CODE') { # hidden attributes...
	} else {			
		return(Package::Transporter::Generator::failure(undef, $sub_name, "::Get_Set_Methods [don't know how to handle object type '$type']"));
	}
	my $code;
	if($what eq 'g') {
		$code = sprintf(q{sub %s { return($_[0]%s); }; },
			$sub_name, $attribute);
	} elsif($what eq 's') {
		$code = sprintf(q{sub %s { $_[0]%s = $_[1]; return; }; },
			$sub_name, $attribute);
	} else {			
		return(Package::Transporter::Generator::failure(undef, $sub_name, "::Get_Set_Methods [name must start with get_ or set_]"));

	}
	$code .= sprintf(q{return(\&%s);}, $sub_name);

	return($code);
}

my $standard_matcher = sub {
	return unless($_[1] =~ m/^(g|s)et_(\w+)/s);
	my $key = $_[0].'::ATB_'.uc($2);
	return unless(defined(&$key));
	return(1);
};
sub matcher {
	return($standard_matcher);
}

1;
