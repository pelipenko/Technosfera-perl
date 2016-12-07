package Local::Source::Array;

use strict;
use warnings;
use parent "Local::Source::Text";

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
	$params{itr} = 0;
	bless \%params, $class;
}

1;