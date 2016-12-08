package Habr;

use strict;
use warnings;
use Mouse;
use DDP;
use feature 'say';
use Client;

sub BUILD {
    my ($self) = @_;

    return;
}

sub _get {
    my ( $self, $href ) = @_;
    my $cl = Client->new();

    $cl->connect($href) or die $@;

    return $cl->parse_new();
}

sub get_href_by_nick {
    my ( $self, $nick ) = @_;
    p $nick;
    return "https://habrahabr.ru/users/$nick/";
}

sub get_user {
    my ( $self, $nick ) = @_;

    my $info;

    $nick =~ s/@//g;
    eval {
        $info = $self->_get( $self->get_href_by_nick($nick) );
        1;
    };
    if ($@) {
        print "$@";
        return undef;
    }

    return $info->{user};
}

sub get_post {
    my ( $self, $post_id ) = @_;

    my $href = 'https://habrahabr.ru/post/' . $post_id . '/#habracut';
    my $info;
    eval {
        $info = $self->_get($href);
        $info->{article}{href} = $href;

        1;
    };
    if ($@) {
        print "$@";
        return undef;
    }

    return $info;
}

sub get_company {
    my ( $self, $href ) = @_;
    my $info;
    eval {
        $info = $self->_get($href);
        1;
    };
    if ($@) {
        print "$@";
        return undef;
    }
    return $info;
}

1;
