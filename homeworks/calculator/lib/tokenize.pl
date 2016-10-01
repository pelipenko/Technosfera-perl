=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, состоящий из отдельных токенов.
Токен - это отдельная логическая часть выражения: число, скобка или арифметическая операция
В случае ошибки в выражении функция должна вызывать die с сообщением об ошибке

Знаки '-' и '+' в первой позиции, или после другой арифметической операции стоит воспринимать
как унарные и можно записывать как "U-" и "U+"

Стоит заметить, что после унарного оператора нельзя использовать бинарные операторы
Например последовательность 1 + - / 2 невалидна. Бинарный оператор / идёт после использования унарного "-"

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

sub tokenize {
chomp(my $expr = shift);
    my @res; 
    # Заполнение массива подходящими данными
    @res=($expr=~m[[-+]|[*/^()]|\d*[.]?\d(?:[eE][-+]?\d+)?]g); 
    for (0..$#res) {
    # Обработка унарных операторов
    if ($res[$_]=~m[^[-+]$] and ($_==0 or $res[$_-1]=~m[^(?:[-+*^/(]|U[-+])$])) {
    $res[$_]="U".$res[$_];
    }  
    # Преобразования в числа
    elsif ($res[$_] =~ m[\d*[.]?\d+(?:[eE][-+]?\d+)?]) {
    $res[$_]+=0;
    # Проверка на несколько чисел подряд
    if (($_!=$#res and $res[$_+1]=~/\d/) or ($_ and $res[$_-1] =~ /\d/)) {
    die "Not enough operators!";
    }
    }
    }
    # Проверка на корректность операторов
    for (0..$#res) {
    if ($res[$_]=~m[^U[-+]$] and ($_==$#res or $res[$_+1]=~ m[^[-+*/^)]$])) {
    die "Incorrect expression after unary operator!";
    }
    elsif ($res[$_]=~m|^[-+*/^]$| and ($_==0 or $_==$#res or $res[$_+1]!~m[\(|\d|U[-+]])) {
    die "Binary operator doesn't have enough operands!";
    }
    }
    return \@res;
}

1;
