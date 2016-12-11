package Local::Reducer;

use strict;
use warnings;

=encoding utf8
=head1 NAME
Local::Reducer - base abstract reducer
=head1 VERSION
Version 1.00
=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
=cut

use Local::Row::Simple;
use Local::Row::JSON;

sub new {
    my $class  = shift;
    my %params = @_;
    bless \%params, $class;
}

sub parsed($) {
  my ($self, $res, $obj) = @_;
  my $field = $self -> {field};
  return $obj -> get($field, 0);
}

sub reduce_n {
  my ($self, $n) = @_;
  my $res = $self -> {reduced};
  for (0..$n-1) {
    my $str = $self -> {source} -> next;
    die "Source doesn't have enough elements" if not defined $str;
    my $obj = $self -> { row_class } -> new(str => $str);
    $res = $self -> parsed($res, $obj);
  }
  $self -> {reduced} = $res;
  return $res;
}

sub reduce_all {
  my ($self, $n) = @_;
  my $res = $self -> {reduced};
  my $str;
  while (defined ($str = $self -> { source } -> next())) {
    my $obj = $self -> { row_class } -> new(str => $str);
    $res = $self -> parsed($res, $obj);
  }
  $self -> {reduced} = $res;
  return $res;
}

sub reduced {
  my $self = shift;
  return $self->{reduced};
}

1;