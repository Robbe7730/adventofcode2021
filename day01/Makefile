prepare_part1:
	as part1.s -o part1.o
	ld part1.o -e start -o part1

prepare_part2:
	as part2.s -o part2.o
	ld part2.o -e start -o part2


run_part1:
	./part1

run_part2:
	./part2


part1: | prepare_part1 run_part1
part2: | prepare_part2 run_part2
