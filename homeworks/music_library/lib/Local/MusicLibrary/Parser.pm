package Local::MusicLibrary::Parser;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = ('parse');

sub parse {
    my ($str) = @_;
    $str =~
m{^[.]/(?<band>\w+)/(?<year>\d+)\s[-]\s(?<album>\w+)/(?<track>\w+)[.](?<format>\w+)$};
    my %n = (
        band   => $+{band},
        year   => $+{year},
        album  => $+{album},
        track  => $+{track},
        format => $+{format}
    );
    return \%n;
}

1;
