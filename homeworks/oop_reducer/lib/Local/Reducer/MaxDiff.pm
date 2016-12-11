package Local::Reducer::MaxDiff;

use strict;
use warnings;
use List::Util 'max';
use parent 'Local::Reducer';

=encoding utf8
=head1 NAME
Local::Reducer - base abstract reducer
=head1 VERSION
Version 1.00
=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
=cut


sub parsed($) {
  my ($self, $res, $obj) = @_;
  my $top = $self -> {top};
  my $bottom = $self -> {bottom};
  return $res = max($res, abs($obj -> get($top, 0) - $obj -> get($bottom, 0)));
}

1;