package Local::MusicLibrary;

use strict;
use warnings;

=encoding utf8
=head1 NAME
Local::MusicLibrary - core music library module
=head1 VERSION
Version 1.00
=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
=cut

use Local::MusicLibrary::Processor qw(filter sorter);
use Local::MusicLibrary::Printer qw(printer);

use Exporter 'import';
our @EXPORT_OK = ('table');

sub table {
    my ( $arr, $opt ) = @_;
    my @table;

    #определение массива с шириной колонок
    my %width;
    for ( keys %{ ${$arr}[0] } ) { $width{$_} = 0 }

    #составление таблицы
    filter( $arr, \@table, $opt, \%width );

    #сортировка таблицы
    sorter( \@table, $opt );

    #вывод на экран
    if ( $$opt{columns} ) {
        unless ( @{ ${$opt}{columns} } ) { return }
        printer( \@table, \%width, $$opt{columns} );
    }
    else {
        printer( \@table, \%width,
            [ "band", "year", "album", "track", "format" ] );
    }
}
1;
