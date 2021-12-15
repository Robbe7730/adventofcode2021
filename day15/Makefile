prepare_part1:
	kotlinc part1.kt -include-runtime -d part1.jar

prepare_part2:
	kotlinc part2.kt -include-runtime -d part2.jar


run_part1:
	java -jar part1.jar

run_part2:
	java -jar part2.jar


part1: | prepare_part1 run_part1
part2: | prepare_part2 run_part2
