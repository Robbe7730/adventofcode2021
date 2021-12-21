<?php declare(strict_types=1);
    $dieState = 1;
    $dieCount = 0;

    function rollDie() {
        GLOBAL $dieState;
        GLOBAL $dieCount;

        $ret = $dieState;

        $dieState++;

        if ($dieState > 100) {
            $dieState -= 100;
        }

        $dieCount++;
        return $ret;
    }

    function roll3Dice() {
        return rollDie() + rollDie() + rollDie();
    }


    function getStartingPositions() {
        $player1 = (int) substr(fgets(STDIN), 28);
        $player2 = (int) substr(fgets(STDIN), 28);
        return [$player1, $player2];
    }

    function move($position) {
        return ($position + roll3Dice() - 1) % 10 + 1;
    }

    function main() {
        GLOBAL $dieCount;
        $positions = getStartingPositions();
        $scores = [0, 0];

        while (($scores[0] < 1000) && ($scores[1] < 1000)) {
            $positions[0] = move($positions[0]);
            $scores[0] += $positions[0];

            if ($scores[0] < 1000) {
                $positions[1] = move($positions[1]);
                $scores[1] += $positions[1];
            }
        }

        return min(...$scores) * $dieCount;
    }

    echo main();
?>
