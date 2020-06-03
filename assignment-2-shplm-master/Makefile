
all: parser

scanner.cpp: scanner.l
	flex -o scanner.cpp scanner.l

parser.cpp parser.hpp: parser.y
	bison -d -o parser.cpp parser.y 

parser: main.cpp scanner.cpp parser.cpp parser.hpp
	g++ main.cpp scanner.cpp parser.cpp -o parser

test:
	./parser < testing_code/p1.py
	./parser < testing_code/p2.py
	./parser < testing_code/p3.py
error1:
	./parser < testing_code/error1.py
error2:
	./parser < testing_code/error2.py
error3:m
	./parser < testing_code/error3.py

check:
	echo "********************************"
	cat example_output/p1.cpp
	echo "********************************"
	cat example_output/p2.cpp
	echo "********************************"
	cat example_output/p3.cpp


clean:
	rm -f parser scanner.cpp parser.cpp parser.hpp parser.output
