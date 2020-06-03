all: compiler

scanner.cpp: scanner.l
	flex -o scanner.cpp scanner.l

parser.cpp parser.hpp: parser.y
	bison -d -o parser.cpp parser.y

#Run llvm compiler
compiler: main.cpp ast.cpp scanner.cpp parser.cpp parser.hpp
	g++ -std=c++11 main.cpp ast.cpp scanner.cpp parser.cpp `llvm-config-7.0-64 --cppflags --ldflags --libs --system-libs all` -o compiler

run1:
	compiler < testing_code/p1.py
run2:
	compiler < testing_code/p2.py
run3:
	compiler < testing_code/p3.py

check1:
	rm -rf sample1.ll
	compiler < testing_code/p1.py > sample1.ll
	diff -w sample1.ll example_output/p1.ll
check2:
	rm -rf sample2.ll
	compiler < testing_code/p2.py > sample2.ll
	diff -w sample2.ll example_output/p2.ll
check3:
	rm -rf sample3.ll
	compiler < testing_code/p3.py > sample3.ll
	diff -w sample3.ll example_output/p3.ll

#Run llvm optmizer
opt:
	parser -O < testing_code/p1.py
	parser -O < testing_code/p2.py
	parser -O < testing_code/p3.py

#Run llvm object code test
test:
	g++ test.cpp output.o -o test
	./test

clean:
	rm -rf test compiler sample1.ll sample2.ll sample3.ll scanner.cpp parser.cpp parser.hpp output.o
