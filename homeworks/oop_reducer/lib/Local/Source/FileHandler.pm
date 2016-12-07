package Local::Source::FileHandler;

use strict;
use warnings;
use parent 'Local::Source';

=encoding utf8
=head1 NAME
Local::Source::FileHandler - get elements from the file
=head1 VERSION
Version 1.00
=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
=cut

sub next {
    my ($self) = @_;
    my $fh     = $self->{fh};
    my $str    = readline($fh);
    if ($str) {
        chomp $str;
        return $str;
    }
    else {
        return undef;
    }
}

1;
