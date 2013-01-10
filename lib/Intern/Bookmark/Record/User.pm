package Intern::Bookmark::Record::User;
use strict;
use warnings;
use Dongry::Database;
use Intern::Bookmark::MySQL;
use Carp qw(croak);
use Intern::Bookmark::Record::Bookmark;
use Intern::Bookmark::Record::Entry;

sub new_from_name {
    my ($class, $name) = @_;
    my $table = $class->db->table('user');
    $table->create({name => $name}, duplicate => 'ignore');
    my $row = $table->find({name => $name});
    return bless {row => $row}, $class;
}

sub find_by_id {
    my ($class, $id) = @_;
    my $row = $class->db->table('user')->find({id => $id}) or return undef;
    return bless {row => $row}, $class;
}

sub db {
    return Dongry::Database->load('bookmark');
}

sub id {
    return $_[0]->{row}->get('id');
}

sub name {
    return $_[0]->{row}->get('name');
}

sub bookmarks {
    my $self = shift;
    my %opts = @_;
    my $page = $opts{page} || 1;
    my $limit = $opts{limit} || 3;
    my $offset = ($page - 1) * $limit;

    return $self->db->table('bookmark')->find_all(
        { user_id => $self->id },
        limit  => $limit,
        offset => $offset,
        order  => ['created' => 'DESC'],
    )->map(sub {
        return Intern::Bookmark::Record::Bookmark->new_from_row($_);
    });
}

sub bookmark_on_entry {
    my ($self, $entry) = @_;
    my $row = $self->db->table('bookmark')->find(
        {
            user_id => $self->id,
            entry_id => $entry->id,
        },
    );
    return $row ? Intern::Bookmark::Record::Bookmark->new_from_row($row) : undef;
}

sub add_bookmark {
    my ($self, %args) = @_;
    my $url = $args{url} or croak q(add_bookmark: parameter 'url' required);

    my $entry = Intern::Bookmark::Record::Entry->new_from_url($url);
    if (my $bookmark = $self->bookmark_on_entry($entry)) {
        $bookmark->comment($args{comment});
        return $bookmark;
    } else {
        return Intern::Bookmark::Record::Bookmark->create(
            user => $self,
            entry => $entry,
            comment => $args{comment},
        );
    }
}

sub delete_bookmark {
    my ($self, $entry) = @_;
    my $bookmark = $self->bookmark_on_entry($entry) or return;
    $bookmark->delete;
    return $bookmark;
}

1;
