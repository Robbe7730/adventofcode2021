<?php declare(strict_types=1);
    $memo = array();
    function getStartingPositions() {
        $player1 = (int) substr(fgets(STDIN), 28);
        $player2 = (int) substr(fgets(STDIN), 28);
        return [$player1, $player2];
    }

    function step($positions, $scores, $player, $roll) {
        GLOBAL $memo;

        $memoIndex = (
            $player +
            $scores[0]    * 10 +
            $scores[1]    * 1000 +
            $positions[0] * 100000 +
            $positions[1] * 10000000 +
            $roll         * 1000000000
        );
        if (isset($memo[$memoIndex])) {
            return $memo[$memoIndex];
        }

        $positions[$player] = ($positions[$player] + $roll - 1) % 10 + 1;
        $scores[$player] += $positions[$player];

        $ret = [0, 0];
        if ($scores[$player] >= 21) {
            $ret[$player] = 1;
            $memo[$memoIndex] = $ret;
            return $ret;
        }

        foreach (range(1, 3) as $firstRoll) {
            foreach (range(1, 3) as $secondRoll) {
                foreach (range(1, 3) as $thirdRoll) {
                    $sub = step($positions, $scores, ($player + 1) % 2, $firstRoll + $secondRoll + $thirdRoll);
                    $ret[0] += $sub[0];
                    $ret[1] += $sub[1];
                }
            }
        }

        $memo[$memoIndex] = $ret;
        return $ret;
    }

    function main() {
        $positions = getStartingPositions();
        $ret = [0, 0];
        foreach (range(1, 3) as $firstRoll) {
            foreach (range(1, 3) as $secondRoll) {
                foreach (range(1, 3) as $thirdRoll) {
                    $sub = step($positions, [0, 0], 0, $firstRoll + $secondRoll + $thirdRoll);
                    $ret[0] += $sub[0];
                    $ret[1] += $sub[1];
                }
            }
        }
        return $ret;
    }

    echo max(main());
?>
