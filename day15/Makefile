prepare_part1:
	kotlinc part1.kt -include-runtime -d part1.jar

prepare_part2:
	echo "Preparing part 2"


run_part1:
	java -jar part1.jar

run_part2:
	echo "Running part 2"


part1: | prepare_part1 run_part1
part2: | prepare_part2 run_part2
