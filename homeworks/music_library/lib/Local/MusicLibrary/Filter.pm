package Local::MusicLibrary::Filter;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = ('filter');

sub filter {
    my ( $arr, $table, $opt, $width ) = @_;
    for my $n (@$arr) {

        my $flag = "";
        for ( keys %$n ) {
            if ( $$opt{$_}
                and ( $$opt{$_} ne $$n{$_} and $_ ne "year" )
                || ( $$opt{$_} != $$n{$_} and $_ eq "year" ) )
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
