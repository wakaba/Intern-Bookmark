package Intern::Bookmark::MySQL;
use strict;
use warnings;
use DateTime;
use Dongry::Type::DateTime;

sub init_by_dsn {
    my ($class, $dsn) = @_;
    
    $Dongry::Database::Registry->{bookmark} = {
        sources => {
            master => {
                dsn => $dsn,
                writable => 1,
            },
            default => {
                dsn => $dsn,
            },
        },
        schema => {
            user => {
                primary_keys => ['id'],
                type => {
                    
                },
            },
            bookmark => {
                primary_keys => ['id'],
                type => {
                    comment => 'text',
                    created => 'timestamp_as_DateTime',
                    updated => 'timestamp_as_DateTime',
                },
                default => {
                    created => sub { DateTime->now(time_zone => 'UTC') },
                    updated => sub { DateTime->now(time_zone => 'UTC') },
                },
            },
            entry => {
                primary_keys => ['id'],
                type => {
                    url => 'text',
                    title => 'text',
                    created => 'timestamp_as_DateTime',
                    updated => 'timestamp_as_DateTime',
                },
                default => {
                    created => sub { DateTime->now(time_zone => 'UTC') },
                    updated => sub { DateTime->now(time_zone => 'UTC') },
                },
            },
        },
    };
}

1;
