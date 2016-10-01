=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, содержащий обратную польскую нотацию
Один элемент массива - это число или арифметическая операция
В случае ошибки функция должна вызывать die с сообщением об ошибке

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
use FindBin;
require "$FindBin::Bin/../lib/tokenize.pl";
# Определение приоритета операторов
sub pr {
	my $op = shift;
	if($op=~m[^[()]$]) {return 0}
	elsif($op=~m[^[-+]$]) {return 1}
	elsif($op=~m[^[*/]$]) {return 2}
	elsif($op=~m[^U[-+]|[\^]$]) {return 3}
}
# Преобразование в обратную польскую нотацию
sub rpn {
	my $expr = shift;
	my $source = tokenize($expr);
	my @rpn;
	my @stack;
	for (@$source) {
	if ($_=~m[\d+]) {push @rpn, $_; next}
        if ($_=~m[^\($]) {push @stack, $_; next}
        if ($_=~m[^\)$]) {
	while (@stack and $stack[-1] ne '(') {push @rpn, pop @stack} 
	pop @stack; next}
	while (@stack and pr($stack[-1]) >= pr($_)) {
	if (pr($stack[-1]) == pr($_) and pr($_) > 2) {last}
	push @rpn, pop @stack;
	}
	push @stack, $_;
	}
	while (@stack) {push @rpn, pop @stack}
	return \@rpn;
}

1;
