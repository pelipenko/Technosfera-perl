#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long;
use DDP;
use JSON::XS;
use Text::CSV;
use FindBin;
use lib $FindBin::Bin . '/../lib/Local/';
use Database;

my $keys = {};
my $refresh;
my $cmd = $ARGV[0];
my $h;

# Получение параметров командной строки
GetOptions(
    'format=s' => \$keys->{format},
    'refresh!' => \$refresh,
    'name=s'   => \$keys->{name},
    'id=i'     => \$keys->{id},
    'post=i'   => \$keys->{post},
    'n=i'      => \$keys->{n}
) or die $@;

$h->{$cmd} = 1;
$h->{keys} =
  { map { $_ => $keys->{$_} } grep { defined $keys->{$_} } keys %$keys };

my $db = Database->new();
my $data;
if ( $h->{user} )
{ # Запрос пользователя, по нику или номеру поста
    if ( $h->{keys}{name} ) {
        $data = $db->get_user( $h->{keys}{name}, $refresh );
    }
    else {
        $data = $db->get_post( $h->{keys}{post}, $refresh )->{author};
    }
}
elsif ( $h->{commenters} ) {    # Запрос комментаторов
    my $p1 = $db->get_post( $h->{keys}{post}, $refresh );
    $data = $db->get_commenters( $p1->{post}{id} );
}
elsif ( $h->{post} ) {          # Запрос post
    $data = $db->get_post( $h->{keys}->{id}, $refresh );
}
elsif ( $h->{self_commenters} )
{    # Запрос комментаторов своих постов
    $data = $db->self_commenters();
}
elsif ( $h->{desert_posts} )
{ # Запрос постов с числом комментов меньше XXX
    $data = $db->desert_posts( $h->{keys}{n} );
}

if ( $h->{keys}{format} eq 'json' ) {
    savejson($data);
}
else {
    savecsv($data);
}

sub savejson {
    my $text = shift;
    my $js   = JSON::XS->new->utf8->encode($text);
    open( my $fjson, '>', 'output.json' );
    $fjson->print($js);
    $fjson->close();
}

sub savecsv {
    my $text = shift;

    my $csv = Text::CSV->new();

    my @columns;

    @columns = keys %$text;

    open( my $fh, '>:encoding(utf8)', 'output.csv' );

    $csv->eol("\r\n");
    $csv->print( $fh, \@columns );
    $csv->eol("\r\n");
    my $t = [];

    my $tmp = [];
    for my $kk (@columns) {
        push @$tmp, $text->{$kk};
    }
    push @$t, $tmp;

    for my $i (@$t) {
        $csv->print( $fh, $i );
        $csv->eol("\r\n");
    }
    $fh->close();
}
