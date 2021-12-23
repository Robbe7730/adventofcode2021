'use strict'
// #############
// #01.2.3.4.56#
// ###7#8#9#A###
//   #B#C#D#E#
//   #########

const readline = require('readline');
const { stdin: input, stdout: output } = require('process')
const PriorityQueue = require('js-priority-queue');

const rl = readline.createInterface({input, output});

const energyRequired = {
    "A": 1,
    "B": 10,
    "C": 100,
    "D": 1000
}

const firstRoomId = {
    "A": 7,
    "B": 8,
    "C": 9,
    "D": 10
}

function readInput(lines) {
    return {
        rooms: [
            lines[1][1],
            lines[1][2],
            lines[1][4],
            lines[1][6],
            lines[1][8],
            lines[1][10],
            lines[1][11],
            lines[2][3],
            lines[2][5],
            lines[2][7],
            lines[2][9],
            lines[3][3],
            lines[3][5],
            lines[3][7],
            lines[3][9],
        ],
        energy: 0,
        numMoves: 0,
    };
}

const stepsRequired = [
    //0  1  2  3  4  5  6  7  8  9  A  B  C  D  E
    [ 0, 1, 3, 5, 7, 9,10, 3, 5, 7, 9, 4, 6, 8,10], // 0
    [ 1, 0, 2, 4, 6, 8, 9, 2, 4, 6, 8, 3, 5, 7, 9], // 1
    [ 3, 2, 0, 2, 4, 6, 7, 2, 2, 4, 6, 3, 3, 5, 7], // 2
    [ 5, 4, 2, 0, 2, 4, 5, 4, 2, 2, 4, 5, 3, 3, 5], // 3
    [ 7, 6, 4, 2, 0, 2, 3, 6, 4, 2, 2, 7, 5, 3, 3], // 4
    [ 9, 8, 6, 4, 2, 0, 1, 8, 6, 4, 2, 9, 7, 5, 3], // 5
    [10, 9, 7, 5, 3, 1, 0, 9, 7, 5, 3,10, 8, 6, 4], // 6
    [ 3, 2, 2, 4, 6, 8, 9, 0, 4, 6, 8, 1, 5, 7, 9], // 7
    [ 5, 4, 2, 2, 4, 6, 7, 4, 0, 4, 6, 5, 1, 5, 7], // 8
    [ 7, 6, 4, 2, 2, 4, 5, 6, 4, 0, 4, 7, 5, 1, 5], // 9
    [ 9, 8, 6, 4, 2, 2, 3, 8, 6, 4, 0, 9, 7, 5, 1], // A
    [ 4, 3, 3, 5, 7, 9,10, 1, 5, 7, 9, 0, 6, 8,10], // B
    [ 6, 5, 3, 3, 5, 7, 8, 5, 1, 5, 7, 6, 0, 6, 8], // C
    [ 8, 7, 5, 3, 3, 5, 6, 7, 5, 1, 5, 8, 6, 0, 6], // D
    [10, 9, 7, 5, 3, 3, 4, 9, 7, 5, 1,10, 8, 6, 0], // E
];

function move(state, from, to) {

    if (state.rooms[from] === '.') {
        throw new Error("Invalid move")
    }
    const ret = {
        rooms: [...state.rooms],
        energy: state.energy + stepsRequired[from][to] * energyRequired[state.rooms[from]],
        numMoves: state.numMoves + stepsRequired[from][to]
    }

    ret.rooms[from] = '.';
    ret.rooms[to] = state.rooms[from];

    return ret;
}

function isCompleted(state) {
    return (
        state.rooms[7] === 'A' &&
        state.rooms[11] === 'A' &&
        state.rooms[8] === 'B' &&
        state.rooms[12] === 'B' &&
        state.rooms[9] === 'C' &&
        state.rooms[13] === 'C' &&
        state.rooms[10] === 'D' &&
        state.rooms[14] === 'D'
    );
}

const typeRoom = {
    7: 'A',
    8: 'B',
    9: 'C',
    10: 'D',
    11: 'A',
    12: 'B',
    13: 'C',
    14: 'D'
}

function tryQueueSwaps(queue, currState, from, to) {
    tryQueue(queue, currState, from, to);
    tryQueue(queue, currState, to, from);
}

function tryQueue(queue, currState, from, to) {
    if (currState.rooms[to] !== '.' || currState.rooms[from] === '.') {
        return
    }

    if ((from >= 7 && to >= 7) || (from <= 6 && to <= 6)) {
        throw Error("Moving in hallway or between rooms");
    }

    const amphipodType = currState.rooms[from];

    if (from <= 6) { // In hallway
        if (typeRoom[to] !== amphipodType) { return; } // Moving to correct room
        if ((to >= 7 && to <= 10) && currState.rooms[to+4] !== typeRoom[to]) { return } // Bottom room is taken if moving from top room
    }

    if (from >= 7 && from <= 10) { // In top room
        if ((amphipodType === typeRoom[from]) && currState.rooms[from + 4] === typeRoom[from+4]) { return } // bottom room has to be different
    }

    if (from >= 11) {
        if (typeRoom[from] === amphipodType) { return }
        if (currState.rooms[from-4] !== '.') { return }
    }

        // (!(from <= 6) || (
        //     amphipodType === typeRoom[to] &&
        //     (!(to >= 7 && to <= 10) || currState.rooms[to+4] === amphipodType) // moving to top room => bottom room is taken
        // )) &&
        // (!(from >= 7 && from <= 10) || ( // In top room =>
        //     (amphipodType !== typeRoom[from] || currState.rooms[from + 4] !== typeRoom[from + 4]) // not already in correct room or room below is not correct yet
        // )) &&
        // (!(from >= 11) || ( // In bottom Room =>
        //     amphipodType !== typeRoom[from] && // not already in correct room
        //     currState.rooms[from-4] === '.' // top room not taken
        // ))
    //console.log(`----- ${from} ${to} -----`)
    //printBoard(currState)
    //printBoard(move(currState, from, to))
    queue.queue(move(currState, from, to));
}

function printBoard(state) {
    console.log(`#############`);
    console.log(`#${state.rooms[0]}${state.rooms[1]}.${state.rooms[2]}.${state.rooms[3]}.${state.rooms[4]}.${state.rooms[5]}${state.rooms[6]}#`);
    console.log(`###${state.rooms[7]}#${state.rooms[8]}#${state.rooms[9]}#${state.rooms[10]}###`);
    console.log(`  #${state.rooms[11]}#${state.rooms[12]}#${state.rooms[13]}#${state.rooms[14]}#  `);
    console.log(`  #########  `);
    console.log(`energy: ${state.energy}, moves: ${state.numMoves}`)
}

function processInput(inputState) {
    const queue = new PriorityQueue({ comparator: (a, b) => (a.energy / a.numMoves) -  (b.energy / b.numMoves) });
    // const queue = new PriorityQueue({ comparator: (a, b) => a.numMoves -  b.numMoves });

    queue.queue(inputState);
    let maxScore = 9999999999;
    let bestState = undefined;

    while (queue.length !== 0) {
        const currState = queue.dequeue();

        if (currState.energy >= maxScore) {
            continue;
        }

        if (isCompleted(currState)) {
            maxScore = currState.energy;
            bestState = currState;
            console.log(currState);
            console.log(queue.length);
            continue;
        }

        // Hallway 0
        if (currState.rooms[1] === '.') {
            tryQueueSwaps(queue, currState, 7, 0);
            tryQueueSwaps(queue, currState, 11, 0);

            if (currState.rooms[2] === '.') {
                tryQueueSwaps(queue, currState, 8, 0);
                tryQueueSwaps(queue, currState, 12, 0);

                if (currState.rooms[3] === '.') {
                    tryQueueSwaps(queue, currState, 9, 0);
                    tryQueueSwaps(queue, currState, 13, 0);

                    if (currState.rooms[4] === '.') {
                        tryQueueSwaps(queue, currState, 10, 0);
                        tryQueueSwaps(queue, currState, 14, 0);
                    }
                }
            }
        }

        // Hallway 1
        tryQueueSwaps(queue, currState, 7, 1);
        tryQueueSwaps(queue, currState, 11, 1);

        if (currState.rooms[2] === '.') {
            tryQueueSwaps(queue, currState, 8, 1);
            tryQueueSwaps(queue, currState, 12, 1);

            if (currState.rooms[3] === '.') {
                tryQueueSwaps(queue, currState, 9, 1);
                tryQueueSwaps(queue, currState, 13, 1);

                if (currState.rooms[4] === '.') {
                    tryQueueSwaps(queue, currState, 10, 1);
                    tryQueueSwaps(queue, currState, 14, 1);
                }
            }
        }

        // Hallway 2
        tryQueueSwaps(queue, currState, 7, 2);
        tryQueueSwaps(queue, currState, 11, 2);

        tryQueueSwaps(queue, currState, 8, 2);
        tryQueueSwaps(queue, currState, 12, 2);

        if (currState.rooms[3] === '.') {
            tryQueueSwaps(queue, currState, 9, 2);
            tryQueueSwaps(queue, currState, 13, 2);

            if (currState.rooms[4] === '.') {
                tryQueueSwaps(queue, currState, 10, 2);
                tryQueueSwaps(queue, currState, 14, 2);
            }
        }

        // Hallway 3
        if (currState.rooms[2] === '.') {
            tryQueueSwaps(queue, currState, 7, 3);
            tryQueueSwaps(queue, currState, 11, 3);
        }

        tryQueueSwaps(queue, currState, 8, 3);
        tryQueueSwaps(queue, currState, 12, 3);

        tryQueueSwaps(queue, currState, 9, 3);
        tryQueueSwaps(queue, currState, 13, 3);

        if (currState.rooms[4] === '.') {
            tryQueueSwaps(queue, currState, 10, 3);
            tryQueueSwaps(queue, currState, 14, 3);
        }

        // Hallway 4
        if (currState.rooms[3] === '.') {
            if (currState.rooms[2] === '.') {
                tryQueueSwaps(queue, currState, 7, 4);
                tryQueueSwaps(queue, currState, 11, 4);
            }

            tryQueueSwaps(queue, currState, 8, 4);
            tryQueueSwaps(queue, currState, 12, 4);
        }

        tryQueueSwaps(queue, currState, 9, 4);
        tryQueueSwaps(queue, currState, 13, 4);

        tryQueueSwaps(queue, currState, 10, 4);
        tryQueueSwaps(queue, currState, 14, 4);

        // Hallway 5
        if (currState.rooms[4] === '.') {
            if (currState.rooms[3] === '.') {
                if (currState.rooms[2] === '.') {
                    tryQueueSwaps(queue, currState, 7, 5);
                    tryQueueSwaps(queue, currState, 11, 5);
                }

                tryQueueSwaps(queue, currState, 8, 5);
                tryQueueSwaps(queue, currState, 12, 5);
            }
            tryQueueSwaps(queue, currState, 9, 5);
            tryQueueSwaps(queue, currState, 13, 5);
        }

        tryQueueSwaps(queue, currState, 10, 5);
        tryQueueSwaps(queue, currState, 14, 5);

        // Hallway 6
        if (currState.rooms[5] === '.') {
            if (currState.rooms[4] === '.') {
                if (currState.rooms[3] === '.') {
                    if (currState.rooms[2] === '.') {
                        tryQueueSwaps(queue, currState, 7, 6);
                        tryQueueSwaps(queue, currState, 11, 6);
                    }

                    tryQueueSwaps(queue, currState, 8, 6);
                    tryQueueSwaps(queue, currState, 12, 6);
                }
                tryQueueSwaps(queue, currState, 9, 6);
                tryQueueSwaps(queue, currState, 13, 6);
            }

            tryQueueSwaps(queue, currState, 10, 6);
            tryQueueSwaps(queue, currState, 14, 6);
        }
    }

    // 16688 -> too high
    // 15370 -> too high
    // 15340 -> too high
    return bestState;
}

function main() {
    const lines = [];

    rl.on('line', (l) => lines.push(l));
    rl.on('close', () => console.log(processInput(readInput(lines))));
}

main();
