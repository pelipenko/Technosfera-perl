#!/usr/bin/env perl

use strict;
use warnings;

use FindBin '$Bin';
use lib "$Bin/../lib";

use Local::MusicLibrary::Parser qw(parse);
use Local::MusicLibrary qw(table);
use Getopt::Long;

#хэш параметров командной строки
my %opt;
GetOptions(
    'band=s'     => \$opt{band},
    'year=s'     => \$opt{year},
    'album=s'    => \$opt{album},
    'track=s'    => \$opt{track},
    'format=s'   => \$opt{format},
    'sort=s'     => \$opt{sort},
    'columns=s@' => \$opt{columns}
);
if ( $opt{columns} ) {
    @{ $opt{columns} } = split( /,/, join( ',', @{ $opt{columns} } ) );
}

#заполнение массива входными данными
my @arr;
while (<>) {
    push @arr, parse($_);
}

#вывод готовой таблицы
table( \@arr, \%opt );
