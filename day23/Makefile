prepare_part1:
	npm install

prepare_part2:
	echo "Preparing part 2"


run_part1:
	node --max-old-space-size=8192 --max-semi-space-size=4096 part1.js

run_part2:
	echo "Running part 2"


part1: | prepare_part1 run_part1
part2: | prepare_part2 run_part2
