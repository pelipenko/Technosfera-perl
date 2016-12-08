package Client;
use strict;
use warnings;

use DDP;
use feature 'say';
use JSON::XS;
use HTML::Entities;
use Encode;
use HTML::TokeParser;
use LWP::UserAgent;
use Array::Iterator;
use Mouse;

has 'ua' => ( 'is' => 'rw', );

has 'answer' => ( 'is' => 'rw', );

has 'hp' => ( 'is' => 'rw', );

has 'conf' => ( 'is' => 'rw', );

has 'status' => ( 'is' => 'rw', );

sub BUILD {
    my ($self) = @_;

    $self->ua( LWP::UserAgent->new() );
    $self->answer( [] );

    warn 'Client was created' . "\n";

    return;
}

sub is_ok {
    my ($self) = @_;

    return ( $self->status eq 'OK' );
}

sub connect {
    my ( $self, $href ) = @_;

    my $resp = $self->ua->get($href);

    if ( $resp->is_success ) {
        $self->conf( { content => $resp->content, cp => 'utf8' } );
        $self->status('OK');
    }
    else {
        $self->status('Error Get');
    }
    return $resp->is_success;
}

sub _parse {
    my ($self) = @_;
    if ( defined $self->conf ) {
        $self->conf->{content} =
          decode( $self->conf->{cp}, $self->conf->{content} );
        $self->hp( HTML::TokeParser->new( \$self->conf->{content} ) );

        my @arr;
        while ( my $tok = $self->hp->get_token() ) {
            push @{ $self->answer }, $tok;
            push @arr, $tok;
        }

        $self->status('OK');
    }
    else {
        $self->status('Error parse');
    }
}

sub get_links {
    my ( $self, $conf ) = @_;

    my @data;
    $conf->{content} = decode( $conf->{cp}, $conf->{content} );

    my $p = HTML::TokeParser->new( \$conf->{content} );

    while ( my $token = $p->get_token() ) {

        # we found our link
        if (   $token->[0] eq 'S'
            && $token->[1] eq 'a'
            && defined $token->[2]->{class}
            && $token->[2]->{class} =~ /^button$/i
            && $token->[2]->{href} =~
            m{^https://habrahabr.ru/post/.*#habracut$} )
        {
            push @data, $token->[2]->{href};
        }
    }

    return \@data;
}

sub parse_new {
    my ($self) = @_;

    $self->_parse();

    my $stat = { user => {}, article => {}, commenters => {} };
    my $iter = Array::Iterator->new( $self->answer );

    while ( my $tok = $iter->get_next() ) {
        if (   $tok->[0] eq 'S'
            && $tok->[1] eq 'div'
            && defined $tok->[2]->{class}
            && $tok->[2]->{class} =~ m/voting-wjt__counter-score js-karma_num/ )
        {
            $stat->{user}{karma} = $iter->get_next()->[1];
        }
        elsif ($tok->[0] eq 'S'
            && $tok->[1] eq 'div'
            && defined $tok->[2]->{class}
            && $tok->[2]->{class} =~
            m/(statistic__value statistic__value_magenta)|(user-rating__value)/
          )
        {
            $stat->{user}{rating} = $iter->get_next()->[1];
        }
        elsif ($tok->[0] eq 'S'
            && $tok->[1] eq 'a'
            && defined $tok->[2]->{class}
            && $tok->[2]->{class} =~ m/author-info__nickname/ )
        {
            $stat->{user}{nick} = $iter->get_next()->[1];
            my $nick = $stat->{user}{nick};
            $nick =~ s/@//gs;
            $stat->{user}{href} = "https://habrahabr.ru/users/" . $nick;
        }
        elsif ($tok->[0] eq 'S'
            && $tok->[1] eq 'a'
            && defined $tok->[2]->{class}
            && $tok->[2]->{class} =~ m/author-info__name/ )
        {
            $stat->{user}{href} = "https://habrahabr.ru/" . $tok->[2]->{href};
            $stat->{user}{nick} = $iter->get_next()->[1];
        }
        elsif ($tok->[0] eq 'S'
            && $tok->[1] eq 'h1'
            && defined $tok->[2]->{class}
            && $tok->[2]->{class} =~ m/post__title/ )
        {
            $stat->{article}{title} = $iter->peek(10)->[1];
        }
        elsif ($tok->[0] eq 'S'
            && $tok->[1] eq 'div'
            && defined $tok->[2]->{class}
            && $tok->[2]->{class} =~ m/views-count_post/ )
        {
            $stat->{article}{views} = $iter->get_next()->[1];
        }
        elsif ($tok->[0] eq 'S'
            && $tok->[1] eq 'span'
            && defined $tok->[2]->{class}
            && $tok->[2]->{class} =~ m/favorite-wjt__counter js-favs_count/ )
        {
            $stat->{article}{favourite} = $iter->get_next()->[1];
        }
        elsif ($tok->[0] eq 'S'
            && $tok->[1] eq 'a'
            && defined $tok->[2]->{class}
            && $tok->[2]->{class} =~ m/comment-item__username/ )
        {
            my $nick = $iter->get_next()->[1];

            if ( defined $stat->{commenters}{$nick} ) {
                $stat->{commenters}{$nick} += 1;
            }
            else {
                $stat->{commenters}{$nick} = 1;
            }
        }
    }
    return $stat;
}

1;
