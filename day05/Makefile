prepare_part1:
	cobc -x -o part1 part1.cob

prepare_part2:
	cobc -x -o part2 part2.cob

run_part1:
	./part1

run_part2:
	./part2

part1: | prepare_part1 run_part1
part2: | prepare_part2 run_part2
