package Local::MusicLibrary::Processor;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw(filter sorter);

sub numfltr    { my ( $a, $b ) = @_; return $a != $b; }
sub stringfltr { my ( $a, $b ) = @_; return $a ne $b; }
sub numsrt    { my ( $a, $b, $k ) = @_; return $$a{$k} <=> $$b{$k}; }
sub stringsrt { my ( $a, $b, $k ) = @_; return $$a{$k} cmp $$b{$k}; }

my $rules = {
    year   => { fltr => \&numfltr,    srt => \&numsrt },
    band   => { fltr => \&stringfltr, srt => \&stringsrt },
    album  => { fltr => \&stringfltr, srt => \&stringsrt },
    track  => { fltr => \&stringfltr, srt => \&stringsrt },
    format => { fltr => \&stringfltr, srt => \&stringsrt }
};

sub filter {
    my ( $arr, $table, $opt, $width ) = @_;
    for my $n (@$arr) {

        my $flag = "";
        for ( keys %$n ) {
            if (    $$opt{$_}
                and $rules->{$_}{fltr}( $$opt{$_}, $$n{$_} ) )
            {
                $flag++;
                last;
            }
        }

        if ($flag) { next }

        push @$table, $n;
        for ( keys %$n ) {
            if ( length $$n{$_} > ${$width}{$_} ) {
                ${$width}{$_} = length $$n{$_};
            }
        }
    }

}

sub sorter {
    my ( $table, $opt ) = @_;
    if ( $$opt{sort} ) {
        @$table =
          sort { $rules->{ $$opt{sort} }{srt}( $a, $b, $$opt{sort} ) } @$table;
    }
}
1;
