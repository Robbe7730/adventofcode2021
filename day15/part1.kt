import java.util.PriorityQueue

fun main() {
    var line: String? = readLine()
    val board: MutableList<MutableList<Int>> = mutableListOf()

    while (line != null) {
        val boardCol: MutableList<Int> = mutableListOf()
        for (value in line) {
            boardCol.add(Character.getNumericValue(value))
        }
        board.add(boardCol)
        line = readLine()
    }

    val queue = PriorityQueue<Triple<Int, Int, Int>>(1, compareBy({ it.first }))
    queue.add(Triple(0, 0, 0))
    val visited: MutableSet<Pair<Int, Int>> = mutableSetOf()

    while (true) {
        val (distance, x, y) = queue.poll()
        if (x == board.size-1 && y == board[0].size-1) {
            println("$distance")
            break
        }

        if (!visited.contains(Pair(x, y))) {
            visited.add(Pair(x, y))
            if (x - 1 >= 0) {
                queue.add(Triple(distance + board[x-1][y], x-1, y))
            }
            if (y - 1 >= 0) {
                queue.add(Triple(distance + board[x][y-1], x, y-1))
            }
            if (x + 1 < board.size) {
                queue.add(Triple(distance + board[x+1][y], x+1, y))
            }
            if (y + 1 < board[0].size) {
                queue.add(Triple(distance + board[x][y+1], x, y+1))
            }
        }
    }
}

fun printBoard(board: MutableList<MutableList<Int>>) {
    for (row in board) {
        for (col in row) {
            print(col.toString().padStart(3))
        }
        println()
    }
}
