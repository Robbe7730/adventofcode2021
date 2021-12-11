package main

import (
	"fmt"
	"bufio"
	"os"
	"strconv"
)

func main(){
	var inputs [10][10]int
	var i int = 0
	var ret int = 0
	var deltas = [3]int{-1, 0, 1};

	scanner := bufio.NewScanner(os.Stdin)
	scanner.Split(bufio.ScanRunes)

	for scanner.Scan() {
		value, err := strconv.Atoi(scanner.Text())

		if err == nil {
			inputs[i/10][i%10] = value
			i++
		}
	}

	for {
		ret++
		for x:=0; x<10; x++ {
			for y:=0; y<10; y++ {
				inputs[x][y]++
			}
		}

		var has_flashed [10][10]bool
		for x:=0; x<10; x++ {
			for y:=0; y<10; y++ {
				has_flashed[x][y] = false
			}
		}
		for flashed := true; flashed; {
			flashed = false
			for x:=0; x<10; x++ {
				for y:=0; y<10; y++ {
					if inputs[x][y] > 9 {
						for _, dx := range deltas {
							if (x+dx >= 0 && x+dx < 10) {
								for _, dy := range deltas {
									if (y+dy >= 0 && y+dy < 10) {
										inputs[x+dx][y+dy]++
									}
								}
							}
						}
						has_flashed[x][y] = true
						inputs[x][y] = 0
						flashed = true
					}
				}
			}
		}
		found_solution := true
		for x:=0; x<10; x++ {
			for y:=0; y<10; y++ {
				if (has_flashed[x][y]) {
					inputs[x][y] = 0
				} else {
					found_solution = false
				}
			}
		}
		if found_solution {
			break
		}
	}
	fmt.Println(ret)
}

func print_board(board [10][10]int) {
	for x:=0; x<10; x++ {
		for y:=0; y<10; y++ {
			fmt.Print(board[x][y])
		}
		fmt.Println()
	}
}
