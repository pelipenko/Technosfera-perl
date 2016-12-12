package Local::Crawler;

use strict;
use warnings;
no warnings 'experimental';
use AnyEvent;
use AnyEvent::HTTP;
use Mojo::DOM;
use Exporter 'import';

our @EXPORT = qw(sorting find_refs);

sub sorting {
    my $hash = shift;
    my @sorted = sort { $$hash{$b} <=> $$hash{$a} } keys %$hash;
    return \@sorted;
}

sub find_refs {
    my ( $host, $body ) = @_;
    my $dom = Mojo::DOM->new($body);
    my @refs;
    my $address1 = $dom->find('a[href^="/"]');
    my $address2 = $dom->find(qq( a[href^="http://"] ));
    my $address3 = $dom->find(qq( a[href^="https://"] ));

    my $cuthost1 = ( $host =~ s{(http://}{}r );
    my $cuthost  = ( $cuthost1 =~ s{(https://}{}r );

    for (@$address1) {
        if ( $_->attr('href') =~ m{^//(?:www.)?$cuthost(\/.*)} ) {
            my $url = $1;
            $url =~ s{/$}{};
            push( @refs, $url );
            next;
        }
        if ( $_->attr('href') =~ m{^//} ) { next; }
        my $url = $_->attr('href');
        $url =~ s{/$}{};
        push( @refs, $url );
    }

    for (@$address2) {
        if ( $_->attr('href') =~ m{http://(?:www.)?$cuthost(\/.*)} ) {
            my $url = $1;
            $url =~ s{/$}{};
            push( @refs, $url );
            next;
        }
    }

    for (@$address3) {
        if ( $_->attr('href') =~ m{https://(?:www.)?$cuthost(\/.*)} ) {
            my $url = $1;
            $url =~ s{/$}{};
            push( @refs, $url );
            next;
        }
    }

    return \@refs;

}
