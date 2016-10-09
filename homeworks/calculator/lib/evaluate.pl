=head1 DESCRIPTION

Эта функция должна принять на вход ссылку на массив, который представляет из себя обратную польскую нотацию,
а на выходе вернуть вычисленное выражение

=cut

use 5.010;
use strict;
use warnings;
use diagnostics;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

sub evaluate {
    my $rpn = shift;
    my @stack;
    for (@$rpn) {
        if    ( $_ eq 'U+' ) { }
        elsif ( $_ eq 'U-' ) { push @stack, -pop(@stack) }
        elsif ( $_ eq '+' )  { push @stack, pop(@stack) + pop @stack }
        elsif ( $_ eq '-' )  { push @stack, -pop(@stack) + pop @stack }
        elsif ( $_ eq '*' )  { push @stack, pop(@stack) * pop @stack }
        elsif ( $_ eq '/' ) {
            push @stack, do {
                my $x = splice @stack, -2, 1;
                my $y = splice @stack, -1, 1;
                $x / $y;
              }
        }
        elsif ( $_ eq '^' ) {
            push @stack, do {
                my $x = splice @stack, -2, 1;
                my $y = splice @stack, -1, 1;
                $x**$y;
              }
        }
        else { push @stack, $_ }
    }
    return 0 + pop @stack;
}
1;
