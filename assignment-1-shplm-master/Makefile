default: scanner.o main.o

scanner.o: scanner.l
	flex -o scanner.cpp scanner.l

main.o: scanner.cpp
	g++ -std=c++11 scanner.cpp -o scanner

test:
	rm -rf *.txt
	./scanner prog_p1.txt < testing_code/p1.py
	./scanner prog_p2.txt < testing_code/p2.py
	./scanner prog_p3.txt < testing_code/p3.py
	./scanner prog_p4.txt < testing_code/p4.py

print:
	echo "***************************"
	cat prog_p1.txt
	echo "***************************"
	cat prog_p2.txt
	echo "***************************"
	cat prog_p3.txt
	echo "***************************"
	cat prog_p4.txt

check:
	echo "********************************"
	cat example_output/p1.out
	echo "********************************"
	cat example_output/p2.out
	echo "********************************"
	cat example_output/p3.out
	echo "********************************"
	cat example_output/p4.out

clean:
	rm -rf scanner.cpp scanner *.o *.txt
