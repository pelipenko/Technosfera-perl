package Local::Reducer::Sum;

use strict;
use warnings;
use DDP;
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

sub reduce_all {
	my $self = shift;
	while(defined(my $value = $self -> parsed)) {
		$res += $value;
		$self -> {value} = $res;} 
	return $res; 
}

sub reduce_n {
	my $self = shift;
	my $n = shift;
	for (1..$n) { 
		if (defined(my $value = $self -> parsed)) {
			$res += $value;
		} 
		else { 
		$self -> {value} = $res; 
		return $res; 
		}
	}
	$self -> {value} = $res;
	return $res;
}

1;