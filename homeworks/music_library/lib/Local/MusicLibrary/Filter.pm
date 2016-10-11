package Local::MusicLibrary::Filter;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw(&filter $string);

sub filter {
    my ( $arr, $table, $opt, $width ) = @_;
    for my $n (@$arr) {
        our $string;
        my $flag = "";
        for ( keys %$n ) {
            if  ( $_ ne "year" ) { $string++; }
            else                 { $string = "" }
            if ( $$opt{$_}
                and ( $string and $$opt{$_} ne $$n{$_}  )
                || ( !($string) and $$opt{$_} != $$n{$_} ) )
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
1;
