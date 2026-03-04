CC = gcc
NVCC = nvcc

run: main.cu seriale.c matrix_generator.c
	gcc -c matrix_generator.c -o matrix_generator.o
	gcc -c seriale.c -o seriale.o
	$(NVCC) -o tester.o main.cu seriale.o matrix_generator.o 
	./tester.o


run_test: SerialeDemo.c
	$(CC) -o SerialeDemo.o SerialeDemo.c 
	./SerialeDemo.o ./test/test1.txt
	./SerialeDemo.o ./test/test2.txt
	./SerialeDemo.o ./test/test3.txt


clean:
	rm -f *.o


