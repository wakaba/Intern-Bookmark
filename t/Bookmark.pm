package t::Bookmark;
use strict;
use warnings;
use lib 'lib', glob 'modules/*/lib';
use Intern::Bookmark::MySQL;
use Dongry::Database;

Intern::Bookmark::MySQL->init_by_dsn('dbi:mysql:dbname=intern_bookmark_test;user=root;password=');

$Intern::Bookmark::Record::Entry::NO_HTTP = 1;

sub truncate_db {
    Dongry::Database->load('bookmark')->execute("TRUNCATE TABLE $_")
        for qw(user entry bookmark);
}

1;
