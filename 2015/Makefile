objects = build/day01.o build/day02.o build/day03.o build/day04.o build/day05.o\
	  build/day06.o build/day07.o build/day08.o build/day09.o build/day10.o\
	  build/day11.o build/day12.o build/day13.o build/day14.o build/day15.o\
	  build/day16.o build/day17.o build/day18.o build/day19.o build/day20.o\
	  build/day21.o build/day22.o build/day23.o build/day24.o build/day25.o\
	  build/main.o

main: $(objects) days.h
	cc -o main -lcurl $(objects)
build/main.o: main.c
	cc -c main.c -o build/main.o -lcurl
build/day01.o: days/day01.c
	cc -c days/day01.c -o build/day01.o
build/day02.o: days/day02.c
	cc -c days/day02.c -o build/day02.o
build/day03.o: days/day03.c
	cc -c days/day03.c -o build/day03.o
build/day04.o: days/day04.c
	cc -c days/day04.c -o build/day04.o
build/day05.o: days/day05.c
	cc -c days/day05.c -o build/day05.o
build/day06.o: days/day06.c
	cc -c days/day06.c -o build/day06.o
build/day07.o: days/day07.c
	cc -c days/day07.c -o build/day07.o
build/day08.o: days/day08.c
	cc -c days/day08.c -o build/day08.o
build/day09.o: days/day09.c
	cc -c days/day09.c -o build/day09.o
build/day10.o: days/day10.c
	cc -c days/day10.c -o build/day10.o
build/day11.o: days/day11.c
	cc -c days/day11.c -o build/day11.o
build/day12.o: days/day12.c
	cc -c days/day12.c -o build/day12.o
build/day13.o: days/day13.c
	cc -c days/day13.c -o build/day13.o
build/day14.o: days/day14.c
	cc -c days/day14.c -o build/day14.o
build/day15.o: days/day15.c
	cc -c days/day15.c -o build/day15.o
build/day16.o: days/day16.c
	cc -c days/day16.c -o build/day16.o
build/day17.o: days/day17.c
	cc -c days/day17.c -o build/day17.o
build/day18.o: days/day18.c
	cc -c days/day18.c -o build/day18.o
build/day19.o: days/day19.c
	cc -c days/day19.c -o build/day19.o
build/day20.o: days/day20.c
	cc -c days/day20.c -o build/day20.o
build/day21.o: days/day21.c
	cc -c days/day21.c -o build/day21.o
build/day22.o: days/day22.c
	cc -c days/day22.c -o build/day22.o
build/day23.o: days/day23.c
	cc -c days/day23.c -o build/day23.o
build/day24.o: days/day24.c
	cc -c days/day24.c -o build/day24.o
build/day25.o: days/day25.c
	cc -c days/day25.c -o build/day25.o

.PHONY: clean
clean: 
	-rm build/* main &>/dev/null
