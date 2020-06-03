all: parser parser-push

scanner.cpp: scanner.l
	flex -o scanner.cpp scanner.l

parser.cpp parser.hpp: parser.y
	bison -d -o parser.cpp parser.y

parser: main.cpp scanner.cpp parser.cpp parser.hpp
	g++ main.cpp scanner.cpp parser.cpp -o parser

scanner-push.cpp: scanner-push.l
	flex -o scanner-push.cpp scanner-push.l

parser-push.cpp parser-push.hpp: parser-push.y
	bison -d -o parser-push.cpp parser-push.y

parser-push: main-push.cpp scanner-push.cpp parser-push.cpp parser-push.hpp
	g++ main-push.cpp scanner-push.cpp parser-push.cpp -o parser-push

clean:
	rm -f parser scanner.cpp parser.cpp parser.hpp
	rm -f parser-push scanner-push.cpp parser-push.cpp parser-push.hpp
