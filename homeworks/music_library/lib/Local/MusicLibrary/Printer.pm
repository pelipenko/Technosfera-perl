package Local::MusicLibrary::Printer;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = ('printer');

sub printer {
    my ( $table, $width, $fields ) = @_;
    unless (@$table) { return }

    print "/";
    for ( 0 .. $#{$fields} ) {
        print "-" x ( $$width{ $$fields[$_] } + 2 );
        unless ( $_ == $#{$fields} ) { print "-" }
    }
    print "\\\n";

    for my $line ( 0 .. $#{$table} ) {
        for ( 0 .. $#{$fields} ) {
            my $str = ${ ${$table}[$line] }{ $$fields[$_] };
            print "| "
              . ( " " x ( $$width{ $$fields[$_] } - length($str) ) )
              . "$str ";
            if ( $_ == $#{$fields} ) { print "|\n" }
        }
        unless ( $line == $#{$table} ) {
            print "|";
            for ( 0 .. $#{$fields} ) {
                print "-" x ( $$width{ $$fields[$_] } + 2 );
                unless ( $_ == $#{$fields} ) { print "+" }
            }
            print "|\n";
        }
    }

    print "\\";
    for ( 0 .. $#{$fields} ) {
        print "-" x ( $$width{ $$fields[$_] } + 2 );
        unless ( $_ == $#{$fields} ) { print "-" }
    }
    print "/\n";
}
1;
