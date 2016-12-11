package Local::Reducer::Sum;

use strict;
use warnings;
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

my $res = 0;

sub parsed($) {
  my ($self, $res, $obj) = @_;
  my $field = $self -> {field};
  return $res + $obj -> get($field, 0);
}

1;