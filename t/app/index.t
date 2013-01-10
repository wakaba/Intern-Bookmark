#!perl
use strict;
use warnings;
use Test::More qw/no_plan/;
use Ridge::Test 'Intern::Bookmark';

is get('/index')->code, 200;

1;
