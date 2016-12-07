package Local::Source::Text;

use strict;
use warnings;
use DDP;

=encoding utf8
=head1 NAME
Local::Source - text source processing
=head1 VERSION
Version 1.00
=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
=cut

sub new {
    my $class  = shift;
    my %params = @_;
    my @text   = split $params{delimeter} ? $params{delimeter} : '\n',
      $params{text};
    $params{array} = \@text;
    $params{itr} = 0;
    bless \%params, $class;
}

sub next {
    my $self = shift;
    return $self->{itr} <= $#{ $self->{array} }
      ? $self->{array}[ $self->{itr}++ ]
      : undef;
}

1;