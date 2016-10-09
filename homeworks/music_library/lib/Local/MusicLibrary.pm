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

use Local::Modules::Filter qw(filter);
use Local::Modules::Printer qw(printer);

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

    #сортировка
    if ( $$opt{sort} ) {
        if ( $$opt{sort} ne "year" ) {
            @table =
              sort { $$a{ $$opt{sort} } cmp $$b{ $$opt{sort} } } @table;
        }
        else {
            @table =
              sort { $$a{ $$opt{sort} } <=> $$b{ $$opt{sort} } } @table;
        }
    }

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
