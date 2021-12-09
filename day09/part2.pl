use feature ':5.10';

my @input = [];
my @visited = [];
my $inChar = 10;
my $row = 0;
my $col = 0;

sub find_basin {
    my $r = $_[0];
    my $c = $_[1];
    my $row = $input[$r];

    if (
        ($r < 0) ||
        ($r >= @input.length) ||
        ($c < 0) ||
        ($c >= @$row.length) ||
        ($input[$r][$c] == 9) || # TODO: maybe assuming edges at 9 is not right
        ($visited[$r][$c] != 0)

    ) {
        return 0;
    }


    my $ret = 1;
    $visited[$r][$c] = 1;

    $ret += find_basin($r+1,$c);
    $ret += find_basin($r-1,$c);
    $ret += find_basin($r,$c+1);
    $ret += find_basin($r,$c-1);

    return $ret;
}

do {
    $in_char = getc(STDIN);
    if (ord($in_char) != 10) {
        $input[$row][$col] = $in_char;
        $visited[$row][$col] = 0;
        $col++;
    } else {
        $row++;
        $col = 0;
    }
} while($! == 0);

pop @input;
pop @visited;

my $ret1 = 0;
my $ret2 = 0;
my $ret3 = 0;
while (my ($r, $row) = each @input) {
    while (my ($c, $val) = each @$row) {
        if (
            (($r-1) < 0 || $val < $input[$r-1][$c]) &&
            (($r+1) >= @input.length || $val < $input[$r+1][$c]) &&
            (($c-1) < 0 || $val < @$row[$c-1]) &&
            (($c+1) >= @$row.length || $val < @$row[$c+1])
        ) {
            my $size = find_basin($r, $c);
            if ($size > $ret1) {
                $ret3 = $ret2;
                $ret2 = $ret1;
                $ret1 = $size;
            } elsif ($size > $ret2) {
                $ret3 = $ret2;
                $ret2 = $size;
            } elsif ($size > $ret3) {
                $ret3 = $size;
            }
        }
    }
}

print $ret1 * $ret2 * $ret3;
print "\n";
