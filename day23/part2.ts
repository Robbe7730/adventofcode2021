import * as readline from 'readline';
import * as process from 'process';
import PriorityQueue from 'js-priority-queue';

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

enum Tile {
    Empty,
    Wall,
    Void,
    A,
    B,
    C,
    D
}

class State {
    board: Tile[][];
    energySpent: number;

    constructor(board: Tile[][], energySpent: number = 0) {
        this.board = board;
        this.energySpent = energySpent;
    }

    public get unsolvedness() {
        let ret = 0;
        this.board.forEach((line, x) => {
            line.forEach((tile, y) => {
                if (doesMove(tile)) {
                    ret += distanceToHome(tile, x, y);
                }
            });
        })
        return ret;
    }
}

function homeY(amphipodType: Tile) {
    switch (amphipodType) {
            case Tile.A:
                return 3;
            case Tile.B:
                return 5;
            case Tile.C:
                return 7;
            case Tile.D:
                return 9;
            default:
                throw new Error('Invalid amphipod type: ' + amphipodType);
    }
}

function distanceToHome(amphipodType: Tile, x: number, y: number): number {
    const targetY = homeY(amphipodType);

    if (y == targetY) {
        return x >= 2 ? 0 : 1;
    }

    return (x + Math.abs(y - targetY));
}

function minimalEnergy(state: State) {
    let ret = 0;
    state.board.forEach((line, i) => {
        line.forEach((tile, j) => {
            if (doesMove(tile)) {
                ret += distanceToHome(tile, i, j) * energyCost(tile);
            }
        })
    })
    return ret;
}

function energyCost(tile: Tile) {
    switch (tile) {
            case Tile.A:
                return 1;
            case Tile.B:
                return 10;
            case Tile.C:
                return 100;
            case Tile.D:
                return 1000;
            default:
                throw new Error('Cannot move tile ' + tile);
    }
}

function tileFromChar(c: string): Tile {
    switch (c) {
            case 'A':
                return Tile.A;
            case 'B':
                return Tile.B;
            case 'C':
                return Tile.C;
            case 'D':
                return Tile.D;
            case '#':
                return Tile.Wall;
            case ' ':
                return Tile.Void;
            case '.':
                return Tile.Empty;
            default:
                throw new Error("Invalid character " + c);
    }
}

function charFromTile(tile: Tile): string {
    switch (tile) {
            case Tile.A:
                return 'A';
            case Tile.B:
                return 'B';
            case Tile.C:
                return 'C';
            case Tile.D:
                return 'D';
            case Tile.Wall:
                return '#';
            case Tile.Void:
                return ' ';
            case Tile.Empty:
                return '.';
            default:
                throw new Error("Invalid tile " + tile);
    }
}

function boardToString(board: Tile[][]): string {
    return (board.map((line) => {
        return line.map(charFromTile).join("")
    })).join("\n");
}

function printBoard(board: Tile[][]) {
    console.log(boardToString(board));
}

function applyPart2(board: Tile[][]): Tile[][] {
    const ret = []

    for (let i = 0; i < board.length-2; i++) {
        ret.push(board[i]);
    }

    ret.push(parseLine("  #D#C#B#A#  "));
    ret.push(parseLine("  #D#B#A#C#  "));

    ret.push(board[board.length - 2]);
    ret.push(board[board.length - 1]);

    return ret;
}

function parseLine(l: string): Tile[] {
    return Array.from(l).map(tileFromChar);
}

function compareStates(a: State, b: State) {
    //if (a.unsolvedness == b.unsolvedness) {
        return a.energySpent - b.energySpent;
    //}
    //return (a.unsolvedness - b.unsolvedness);
}

function doesMove(tile: Tile): boolean {
    return tile === Tile.A ||
        tile === Tile.B ||
        tile === Tile.C ||
        tile === Tile.D;
}

function typeFor(y: number): Tile {
    switch (y) {
            case 3:
                return Tile.A;
            case 5:
                return Tile.B;
            case 7:
                return Tile.C;
            case 9:
                return Tile.D;
            default:
                throw new Error('No amphipod lives at ' + y)
    }
}

// fromX, fromY needs to be an amphipod, toX, toY needs to be empty
function move(currState: State, fromX: number, fromY: number, toX: number, toY:number): State {
    const newState: State = new State(
        currState.board.map(l => [...l]),
        currState.energySpent + (Math.abs(fromX - toX) + Math.abs(fromY - toY)) * energyCost(currState.board[fromX][fromY])
    );

    newState.board[toX][toY] = newState.board[fromX][fromY];
    newState.board[fromX][fromY] = Tile.Empty;

    // printBoard(newState.board);
    // console.log(newState.energySpent);

    return newState;
}

function pathClear(state: State, fromX: number, fromY: number, toX: number, toY: number): boolean {
    // Move up to the hallway
    for (let x = fromX-1; x >= 2; x--) {
        if (state.board[x][fromY] !== Tile.Empty) {
            return false;
        }
    }

    // Move in the hallway
    if (fromY > toY) {
        for (let i = fromY - 1; i >= toY; i--) {
            if (state.board[1][i] !== Tile.Empty) {
                return false;
            }
        }
    } else if (fromY < toY) {
        for (let i = toY; i >= fromY + 1; i--) {
            if (state.board[1][i] !== Tile.Empty) {
                return false;
            }
        }
    } else {
        throw new Error("Cannot move vertically")
    }

    // Move into the room
    for (let x = 2; x <= toX; x++) {
        if (state.board[x][toY] !== Tile.Empty) {
            return false;
        }
    }

    return true;
}

function tryQueueIntoRoom(bestEnergy: Map<string,number>, queue: PriorityQueue<State>, currState: State, fromX: number, fromY: number) {
    const amphipodType = currState.board[fromX][fromY];
    const targetY = homeY(amphipodType);
    let targetX = -1;

    for (let i = currState.board.length - 2; i >= 2; i--) {
        const roomTile = currState.board[i][targetY];
        if (targetX === -1 && roomTile === Tile.Empty) {
            targetX = i;
        }

        if (roomTile !== Tile.Empty && roomTile !== amphipodType) {
            return;
        }
    }

    if (pathClear(currState, fromX, fromY, targetX, targetY)) {
        const newState = move(currState, fromX, fromY, targetX, targetY);
        const boardStr = boardToString(newState.board)
        const newBestEnergy = bestEnergy.get(boardStr) || 99999999;
        if (newState.energySpent < newBestEnergy) {
            bestEnergy.set(boardStr, newState.energySpent);
            queue.queue(newState);
        }
    }
}

function tryQueueIntoHallway(bestEnergy: Map<string, number>, queue: PriorityQueue<State>, currState: State, fromX: number, fromY: number) {
    const amphipodType = currState.board[fromX][fromY];
    if (fromY == homeY(amphipodType)) {
        let shouldSkip = true;
        for (let x = 2; x < currState.board.length - 1; x++) {
            if (currState.board[x][fromY] !== Tile.Empty && currState.board[x][fromY] !== amphipodType) {
                shouldSkip = false;
            }
        }

        if (shouldSkip) {
            return;
        }
    }

    for (const toY of [1, 2, 4, 6, 8, 10, 11]) {
        if (pathClear(currState, fromX, fromY, 1, toY)) {
            const newState = move(currState, fromX, fromY, 1, toY);
            const boardStr = boardToString(newState.board)
            const newBestEnergy = bestEnergy.get(boardStr) || 99999999;
            if (newState.energySpent < newBestEnergy) {
                bestEnergy.set(boardStr, newState.energySpent);
                queue.queue(newState);
            }
        }
    }

}

function solvedBoardLike(board: Tile[][]) {
    return board.map((line, x) => {
        if (x == 1) {
            const newLine = [...line];
            for (let i = 1; i < line.length - 1; i++) {
                newLine[i] = Tile.Empty
            }
            return newLine;
        } else if (x >= 2 && x <= board.length - 2) {
            const newLine = [...line];
            newLine[3] = Tile.A;
            newLine[5] = Tile.B;
            newLine[7] = Tile.C;
            newLine[9] = Tile.D;
            return newLine;
        } else {
            return line;
        }
    })
}

function solve(board: Tile[][]): number {
    const queue = new PriorityQueue({comparator: compareStates})

    let currState: State = new State(board);

    const bestEnergy: Map<string, number> = new Map();

    while(true) {
        currState.board.forEach((line, x) => {
            line.forEach((tile, y) => {
                if (doesMove(tile)) {
                    if (x == 1) {
                        tryQueueIntoRoom(bestEnergy, queue, currState, x, y);
                    } else {
                        tryQueueIntoHallway(bestEnergy, queue, currState, x, y);
                    }
                }
            })
        })

        try {
            currState = queue.dequeue();
        } catch {
            const solvedBoardString: string = boardToString(solvedBoardLike(currState.board));
            return bestEnergy.get(solvedBoardString) || -1;
        }
    }
}

function main() {
    const board: Tile[][] = [];

    rl.on('line', (l: string) => {
        board.push(parseLine(l));
    });
    // This implementation also solves part 1... (and way quicker than the js implementation)
    // rl.on('close', () => console.log(solve(board)));
    rl.on('close', () => console.log(solve(applyPart2(board))));
}

main();
