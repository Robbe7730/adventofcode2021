prepare_part1:
	gcc -o part1 packet_reader.h packet_reader.c bitstream.h bitstream.c dyn_string.c dyn_string.h part1.h part1.c

prepare_part2:
	gcc -o part2 packet_reader.h packet_reader.c bitstream.h bitstream.c dyn_string.c dyn_string.h part2.h part2.c


run_part1:
	./part1

run_part2:
	./part2


part1: | prepare_part1 run_part1
part2: | prepare_part2 run_part2
