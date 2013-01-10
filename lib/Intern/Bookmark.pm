package Intern::Bookmark;
use strict;
use warnings;
use base qw/Ridge/;
use Intern::Bookmark::Record::User;

__PACKAGE__->configure;

sub user {
    my ($self) = @_;
    if (my $name = $self->req->env->{'hatena.user'}) {
        my $user = Intern::Bookmark::Record::User->new_from_name($name);
    } else {
        '';
    }
}

1;
