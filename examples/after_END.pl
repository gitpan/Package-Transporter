#!/usr/bin/perl -W -T
use strict;

use Package::Transporter sub{eval shift}, sub {
	my $generator = $_[0]->create_generator(
		'::Potential::After_END', __FILE__);
	$_[0]->register_potential($generator, 'FOR_SELF');
};

yn(!potentially_defined('hello_worlds'));
yn(potentially_defined('hello_world'));
yn(!defined(&hello_world));

hello_world();

yn(defined(&hello_world));

exit(0);

__END__
sub yn {
	print STDOUT ($_[0] ? 'Yes' : 'No'), "\n";
}
sub hello_world {
	print "Hello World.\n";
}
sub hello_world {
	print "Hello World.\n";
}
sub salut_monde {
	print "Hello World.\n";
}
