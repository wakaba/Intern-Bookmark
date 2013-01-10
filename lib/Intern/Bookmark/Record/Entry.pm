package Intern::Bookmark::Record::Entry;
use strict;
use warnings;
use Dongry::Database;
use Intern::Bookmark::MySQL;
use Intern::Bookmark::Record::Bookmark;
use Intern::Bookmark::Record::User;
use LWP::UserAgent;
use DateTime;

our $NO_HTTP;

sub new_from_row {
    return bless {row => $_[1]}, $_[0];
}

sub new_from_url {
    my ($class, $url) = @_;
    my $self = $class->find_by_url($url);
    unless ($self) {
        $self = $class->create_by_url($url);
        $self->update_title;
    }
    return $self;
}

sub find_by_id {
    my ($class, $id) = @_;
    my $row = $class->db->table('entry')->find({id => $id}) or return undef;
    return bless {row => $row}, $class;
}

sub find_by_url {
    my ($class, $url) = @_;
    my $row = $class->db->table('entry')->find({url => $url})
        or return undef;
    return $class->new_from_row($row);
}

sub create_by_url {
    my ($class, $url) = @_;
    $class->db->table('entry')->create({
        url => $url,
    });
    my $row = $class->db->table('entry')->find({url => $url});
    return $class->new_from_row($row);
}

sub db {
    return Dongry::Database->load('bookmark');
}

sub id {
    return $_[0]->{row}->get('id');
}

sub url {
    return $_[0]->{row}->get('url');
}

sub title {
    return $_[0]->{row}->get('title');
}

sub updated {
    return $_[0]->{row}->get('updated');
}

sub bookmarks {
    my $self = shift;
    return $self->db->table('bookmark')->find_all(
        {entry_id => $self->id},
        order => [created => 'DESC']
    )->map(sub {
        return Intern::Bookmark::Record::Bookmark->new_from_row($_);
    });
}

sub update_title {
    my $self = shift;

    return if $NO_HTTP;

    my $ua = LWP::UserAgent->new(timeout => 15);
    my $res = $ua->get($self->url);
    if ($res->is_error) {
        warn sprintf '%s: %s', $self->url, $res->status_line;
        return;
    }

    my ($title) = $res->decoded_content =~ m#<title>(.+?)</title>#s;
    return unless defined $title;

    $self->{row}->update({
        title => $title,
        updated => DateTime->now(time_zone => 'UTC'),
    });
    return 1;
}

sub as_string {
    my $self = shift;

    return sprintf '[%d] %s <%s>', (
        $self->id,
        $self->title,
        $self->url,
    );
}

1;
