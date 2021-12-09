use feature ':5.10';
my @input = [];
my $inChar = 10;
my $row = 0;
my $col = 0;

do {
    $in_char = getc(STDIN);
    if (ord($in_char) != 10) {
        $input[$row][$col] = $in_char;
        $col++;
    } else {
        $row++;
        $col = 0;
    }
} while($! == 0);

pop @input;

my $ret = 0;
while (my ($r, $row) = each @input) {
    while (my ($c, $val) = each @$row) {
        if (
            (($r-1) < 0 || $val < $input[$r-1][$c]) &&
            (($r+1) >= @input.length || $val < $input[$r+1][$c]) &&
            (($c-1) < 0 || $val < @$row[$c-1]) &&
            (($c+1) >= @$row.length || $val < @$row[$c+1])
        ) {
            $ret += $val + 1;
        }
    }
}

print "$ret\n"
