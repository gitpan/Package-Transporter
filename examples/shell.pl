#!/usr/bin/perl -W -T
use strict;

delete($ENV{'ENV'});
$ENV{'PATH'} = '/usr/local/bin:/usr/bin:/bin';
#$ENV{'PATH'} = join(':', grep($_ =~ m/^\/(opt|usr)/, split(':', $ENV{'PATH'})));

use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_potential('::Shell', 'FOR_SELF');
};

sub yn($) { print STDERR ($_[0] ? 'Yes' : 'No'), "\n"; };

yn(!defined(&shell_ls));
yn(potentially_defined('shell_ls'));

print STDOUT shell_ls('-l');

yn(defined(&shell_ls));
exit(0);
