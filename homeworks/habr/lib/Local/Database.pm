package Database;
use strict;
use warnings;

use DDP;
use feature 'say';
use DBI;
use Client;
use FindBin;
use Habr;
use Mouse;

has 'users' => ( 'is' => 'rw', );

has 'articles' => ( 'is' => 'rw', );

has 'dbh' => ( 'is' => 'rw', );

has 'client' => ( 'is' => 'rw', );

sub BUILD {
    my ($self) = @_;

    my $settings = sub {
        open( my $f, '<', $FindBin::Bin . '/../settings.json' ) or die $@;
        my $json = join "", grep { $_ =~ s/(\s|\n)//gs } <$f>;
        JSON::XS->new->utf8->decode($json);
      }
      ->();

    $self->dbh(
        DBI->connect(
            "dbi:mysql:" . $settings->{dbname} . ":localhost",
            $settings->{username},
            $settings->{password},
            { mysql_enable_utf8 => 1 }
        )
    );

    $self->client( Client->new() );

    $self->cache_users();
    $self->cache_articles();

    warn 'DataBase mod was created' . "\n";

    return;
}

sub add_user {
    my ( $self, $user, $refresh ) = @_;

    die unless ( defined $user );

    if ( $self->users->{ $user->{nick} } ) {
        if ($refresh) {
            $user->{id} = $self->users->{ $user->{nick} }{id};
            $self->update_user($user);
        }
        return;
    }

    warn 'add_user ' . $user->{nick};
    p $user;

    my $sql_usr =
      'INSERT INTO `users` (nick, rating, karma, href) VALUES (?, ?, ?, ?)';

    my $sth = $self->dbh->prepare($sql_usr) or die $self->dbh->errstr;
    eval {
        $sth->execute( $user->{nick}, $user->{rating}, $user->{karma},
            $user->{href} )
          or die $sth->errstr;
        $self->users->{ $user->{nick} } =
          { id => $sth->{mysql_insertid}, %{$user} };

        1;
    };
    if ($@) {
        warn 'This user is already exist' . "\n";
        $self->cache_users();
    }

    warn 'User ' . $user->{nick} . ' added!' . "\n";
}

sub add_article {
    my ( $self, $art, $usr, $refresh ) = @_;

    unless ($refresh) {
        return if ( defined $self->articles->{ $art->{href} } );
    }

    warn 'add_article';

    unless ( defined $art->{user_id} ) {
        p $usr;
        $art->{user_id} = $self->get_user( $usr->{nick} )->{id};
    }

    p $art;

    my $sql_dat;
    my $keys = [
        $art->{href},  $art->{title}, $art->{views},
        $art->{stars}, $art->{user_id}
    ];
    if ( defined $self->articles->{ $art->{href} } ) {
        $sql_dat =
'UPDATE `data` SET href=?, title=?, views=?, stars=?, user_id=? WHERE href=?';
        push @$keys, $art->{href};
    }
    else {
        $sql_dat =
'INSERT INTO `data` (href, title, views, stars, user_id) VALUES (?, ?, ?, ?, ?)';
    }

    my $sth = $self->dbh->prepare($sql_dat) or die $self->dbh->errstr;
    eval {
        $sth->execute(@$keys)
          or die $sth->errstr;
        1;
    };
    if ($@) {
        die $sth->errstr;
    }

    $self->articles->{ $art->{href} } = {
        id => $sth->{mysql_insertid},
        %{$art},
        user => { %{$usr} }
    };
}

sub update_commenter {
    my ( $self, $com ) = @_;

    warn 'Try to update commenter' . "\n";
    p $com;

    my $sql_com =
'UPDATE `commenters` SET comment_count = ? WHERE post_id = ? and user_id = ?';
    my $sth = $self->dbh->prepare($sql_com) or die $self->dbh->errstr;
    eval {
        $sth->execute( $com->{comment_count}, $com->{post_id}, $com->{user_id} )
          or die $sth->errstr;
        1;
    };
    if ($@) {
        warn $sth->errstr . "\n";
        warn 'first comment from user_id '
          . $com->{user_id}
          . ' in this article' . "\n";
        return undef;
    }
    1;
}

sub add_commenters {
    my ( $self, $com ) = @_;

    warn 'ADD commenters' . "\n";

    my $sql_com =
'INSERT INTO `commenters` (post_id, user_id, comment_count) VALUES (?, ?, ?)';

    my $sth = $self->dbh->prepare($sql_com) or die $self->dbh->errstr;
    eval {
        for my $nick ( keys %{ $com->{commenters} } ) {
            my $comm_count = $com->{commenters}{$nick};

            my $user = $self->get_user($nick);
            die unless ($user);

            my $res = $self->update_commenter(
                {
                    post_id       => $com->{post_id},
                    user_id       => $user->{id},
                    comment_count => $comm_count
                }
            );

            next if ($res);

            $sth->execute( $com->{post_id}, $user->{id}, $comm_count )
              or die $sth->errstr;
        }
        1;
    };
    if ($@) {
        warn $sth->errstr;
        warn $@ . "\n";
        die;
    }
}

sub update_user {
    my ( $self, $user ) = @_;

    warn "Update user $user->{nick}\n";

    my $sql_usr =
      'UPDATE `users` SET nick=?, rating=?, karma=?, href=? WHERE id=?';

    my $sth = $self->dbh->prepare($sql_usr) or die $self->dbh->errstr;
    eval {
        $sth->execute(
            $user->{nick}, $user->{rating}, $user->{karma},
            $user->{href}, $user->{id}
        ) or die $sth->errstr;
        $self->users->{ $user->{nick} } =
          { id => $sth->{mysql_insertid}, %{$user} };

        1;
    };
    if ($@) {
        warn 'User `id` = ' . $user->{id} . ' not found' . "\n";
        $self->add_user($user);
    }
}

sub cache_users {
    my ($self) = @_;

    $self->users(
        $self->dbh->selectall_hashref( 'SELECT * FROM `users`', ['nick'] ) );

    for my $nick ( keys %{ $self->users } ) {
        unless ( defined $self->users->{$nick}{href} ) {
            $self->update_user(
                {
                    %{ $self->users->{$nick} },
                    href => Habr->new()->get_href_by_nick($nick)
                }
            );
        }
    }

    warn 'Users were updated' . "\n";
}

sub cache_articles {
    my ($self) = @_;

    $self->articles(
        $self->dbh->selectall_hashref( 'SELECT * FROM `data`', ['href'] ) );

    warn 'Articles were updated' . "\n";
}

sub select_user {
    my ( $self, $q ) = @_;

    my $usr =
      $self->dbh->selectall_hashref( 'SELECT * FROM `users` WHERE id = ?',
        'nick', {}, $q->{id} );

    p $usr;
    return $usr;
}

sub get_user {
    my ( $self, $nick, $refresh, $company ) = @_;

    return undef unless ( defined $nick );

    $nick =~ s/@//;

    unless ($refresh) {
        return $self->users->{ '@' . $nick }
          if ( $self->users->{ '@' . $nick } );
        return $self->users->{$nick} if ( $self->users->{$nick} );
    }

    warn 'download new user from habr ' . $nick . "\n";

    my $user = Habr->new()->get_user($nick);

    unless ( defined $user ) {
        warn 'Download new company from habr ' . $nick . "\n";
        $user = Habr->new()->get_company($company);
        return undef unless ($user);
        $user->{user}{karma} = "0,0";
        $user = $user->{user};
    }

    $self->add_user( $user, $refresh );
    return $self->users->{ $user->{nick} };
    print "$user";
}

sub get_post {
    my ( $self, $post_id, $refresh ) = @_;

    my $key = 'https://habrahabr.ru/post/' . $post_id . '/#habracut';

    my $r = $self->articles->{$key};

    if ( $r and !$refresh ) {
        return {
            post   => $r,
            author => $self->select_user( { id => $r->{user_id} } ),
        };
    }

    my $info = Habr->new()->get_post($post_id);
    return undef unless ( defined $info );

    my $uid =
      $self->get_user( $info->{user}{nick}, $refresh, $info->{user}{href} )
      ->{id};
    $self->add_article( { %{ $info->{article} }, user_id => $uid },
        $info->{user}, $refresh );

    return $self->articles->{$key};
}

sub get_commenters {
    my ( $self, $post_id ) = @_;

    die unless ( defined $post_id );

    my $sql_com =
'SELECT * FROM `commenters` as c JOIN `users` as u on c.user_id = u.id WHERE post_id=?';
    my $res = $self->dbh->selectall_hashref( $sql_com, 'nick', {}, $post_id );

    return $res;
}

sub self_commenters {
    my ($self) = @_;

    my $sql_self =
        'SELECT * FROM users as u JOIN (commenters as c '
      . 'JOIN data as d on (c.post_id = d.id and c.user_id = d.user_id)) on c.user_id = id  '
      . 'GROUP BY u.nick';
    my $coms = $self->dbh->selectall_hashref( $sql_self, ['nick'] );
    return $coms;
}

sub desert_posts {
    my ( $self, $min_count ) = @_;

    my $sql_desert =
        'SELECT * FROM data as d '
      . 'JOIN commenters as c on (c.post_id = d.id '
      . 'and (SELECT SUM(comment_count) FROM commenters as c) < ?)';
    my $posts =
      $self->dbh->selectall_hashref( $sql_desert, ['href'], {}, $min_count );
    return $posts;
}

1;
