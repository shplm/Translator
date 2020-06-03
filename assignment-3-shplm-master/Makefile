# all: parse

# parser.cpp parser.hpp: parser.y
# 	bison -d -o parser.cpp parser.y

# scanner.cpp: scanner.l
# 	flex -o scanner.cpp scanner.l

# parse: main.cpp parser.cpp scanner.cpp
# 	g++ main.cpp parser.cpp scanner.cpp -o parse

# clean:
# 	rm -f parse scanner.cpp parser.cpp parser.hpp


all: parse

parser.cpp parser.hpp: parser.y
	bison -d -o parser.cpp parser.y

scanner.cpp: scanner.l
	flex -o scanner.cpp scanner.l

parse: main.cpp parser.cpp scanner.cpp
	g++ -std=c++11 main.cpp parser.cpp scanner.cpp Astree.cpp -o parse

test:
	rm -rf try*
	parse < testing_code/p1.py > try1.gv
	parse < testing_code/p2.py > try2.gv
	parse < testing_code/p3.py > try3.gv

check1:
	diff try1.gv example_output/p1.gv
check2:
	diff try2.gv example_output/p2.gv
check3:
	diff try3.gv example_output/p3.gv

clean:
	rm -f parse scanner.cpp parser.cpp parser.hpp try* *.gz *.png
