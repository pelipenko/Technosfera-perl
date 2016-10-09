package Local::Modules::Filter;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = ('filter');

sub filter {
    my ( $arr, $table, $opt, $width ) = @_;
    for my $n (@$arr) {

        if (   ( $$opt{band} and $$opt{band} ne $$n{band} )
            or ( $$opt{year}   and $$opt{year} != $$n{year} )
            or ( $$opt{album}  and $$opt{album} ne $$n{album} )
            or ( $$opt{track}  and $$opt{track} ne $$n{track} )
            or ( $$opt{format} and $$opt{format} ne $$n{format} ) )
        {
            next;
        }

        push @$table, $n;
        for ( keys %$n ) {
            if ( length $$n{$_} > ${$width}{$_} ) {
                ${$width}{$_} = length $$n{$_};
            }
        }

    }
}
1;
