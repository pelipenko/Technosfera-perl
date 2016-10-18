package Local::JSONParser;

use strict;
use base qw(Exporter);
our @EXPORT = qw( parse_json );

sub parse_json {
    my $source = shift;

    # use JSON::XS;
    # return JSON::XS->new->utf8->decode($source);
    my $JSON = match($source);
    return $JSON;
}

# Обработка элементов по соответствующих шаблонам
sub match {
    my $source = shift;
    $source =~ s/^\s+//;
    $source =~ s/\s+$//;

    # Число
    if ( $source =~ m/^[-+]?\d*[,\.]?\d+(?:[eE][-+]?\d+)?$/ ) {
        return $source;
    }

    # null, true, false
    if ( $source =~ m/^[true|false|null]$/ ) { return $source; }

    # Строка
    if ( $source =~ m/^\"(?:\\.|[^\"])*+\"$/ ) {
        for ($source) {
            s/^"//;
            s/"$//;
            s/\\f/\f/g;
            s/\\t/\t/g;
            s/\\r/\r/g;
            s/\\n/\n/g;
            s/\\"/"/g;
            s/\\u(\d{4})/chr(hex($1))/ge;

        }
        return $source;
    }

    # Массив
    if ( $source =~ m/^\[(.*)\]/s ) { return match_array($1) }

    # Объект
    if ( $source =~ m/^{(.*)}/s ) { return match_hash($1); }

    else { return die "Error" }
}

# Обработка массива
sub match_array {
    my $source = shift;
    my @arr;
    $source =~ s/^\s+//;
    $source =~ s/\s+$//;
    while (
        $source =~ m/(?<object>\{.*\})
|(?<array>\[.*\])
|(?<value>(\"(?:\\.|[^\"])*+\"|\w+)
)/gxms
      )
    {
        if    ( ( $+{value} ) )  { push @arr, match( $+{value} ) }
        elsif ( ( $+{object} ) ) { push @arr, match( $+{object} ) }
        elsif ( ( $+{array} ) )  { push @arr, match( $+{array} ) }
    }
    if ( $source ne '' and !@arr ) { return die "Error: $_"; }
    return \@arr;
}

# Обработка объекта
sub match_hash {
    my $source = shift;
    my %h;
    $source =~ s/^\s+//;
    $source =~ s/\s+$//;
    while (
        $source =~ m/((?<key>(\".+?\"|\w+?))(\s*)\:
(?<value>(\"(?:\\.|[^\"])*+\"|\[.*\]|\{.*\}|.+?))(\,|$)
)/gxms
      )
    {

        if ( defined( $+{key} ) and defined( $+{value} ) ) {
            my $key   = $+{key};
            my $value = $+{value};
            if ( $key =~ m/\"(?:\\.|[^\"])*+\"/ ) {
                $key =~ s/^\"//;
                $key =~ s/\"$//;
            }
            $h{$key} = match($value);
        }
        elsif ( ( $+{object} ) ) { %h = match_hash( $+{object} ) }
        elsif ( ( $+{array} ) )  { %h = match_array( $+{array} ); }
    }
    if ( $source ne '' and !%h ) { return die "Error: $_" }

    return \%h;
}

1;
