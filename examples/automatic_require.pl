#!/usr/bin/perl -W -T
use strict;

use Package::Transporter sub{eval shift}, sub {
	$_[0]->register_potential('::Automatic_Require', 'FOR_ANY');
};

print CGI->h1->('Hello World.'), "\n";
exit(0);
