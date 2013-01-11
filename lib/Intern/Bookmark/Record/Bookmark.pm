package Intern::Bookmark::Record::Bookmark;
use strict;
use warnings;
use Dongry::Database;
use Intern::Bookmark::MySQL;
use Intern::Bookmark::Record::Entry;
use Intern::Bookmark::Record::User;

sub new_from_row {
    return bless {row => $_[1]}, $_[0];
}

sub create {
    my ($class, %args) = @_;
    $class->db->table('bookmark')->create({
        user_id => $args{user}->id,
        entry_id => $args{entry}->id,
        comment => $args{comment},
    });
    my $row = $class->db->table('bookmark')->find({
        user_id => $args{user}->id,
        entry_id => $args{entry}->id,
    });
    return $class->new_from_row($row);
}

sub db {
    return Dongry::Database->load('bookmark');
}

sub id {
    return $_[0]->{row}->get('id');
}

sub entry_id {
    return $_[0]->{row}->get('entry_id');
}

sub user_id {
    return $_[0]->{row}->get('user_id');
}

sub comment {
    return $_[0]->{row}->get('comment');
}

sub created {
    return $_[0]->{row}->get('created');
}

sub entry {
    my $self = shift;
    return Intern::Bookmark::Record::Entry->find_by_id($self->entry_id);
}

sub user {
    my $self = shift;
    return Intern::Bookmark::Record::User->find_by_id($self->user_id);
}

sub update {
    my $self = shift;
    $self->{row}->update({@_});
}

sub delete {
    my $self = shift;
    $self->{row}->delete;
}

sub as_string {
    my $self = shift;

    return sprintf "%s\n  @%s %s", (
        $self->entry->as_string,
        $self->created->ymd,
        $self->comment // '',
    );
}

1;
