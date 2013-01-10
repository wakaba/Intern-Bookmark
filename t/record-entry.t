package t::Intern::Bookmark::Record::Entry;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use t::Bookmark;

sub startup : Test(startup => 1) {
    use_ok 'Intern::Bookmark::Record::Entry';
    t::Bookmark->truncate_db;
}

sub updated_on : Test(1) {
    my $e = Intern::Bookmark::Record::Entry->new_from_url('http://test1/');
    $e->title('hoge');
    is $e->updated . '', DateTime->now . '', 'updated_on 更新された';
}

__PACKAGE__->runtests;
