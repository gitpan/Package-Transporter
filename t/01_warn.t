#!/usr/bin/perl -W -T
use strict;
use Test::Simple tests => 1;

ok(1, 'You are dealing with an experimental module (Package::Transporter).');
warn('You are dealing with an experimental module (Package::Transporter).');
exit(0);