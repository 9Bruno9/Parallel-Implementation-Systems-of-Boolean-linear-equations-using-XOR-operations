CC = gcc
NVCC = nvcc
TARGETS = tester SerialeDemo


run: main.cu seriale.c matrix_generator.c
	gcc -c matrix_generator.c -o matrix_generator.o
	gcc -c seriale.c -o seriale.o
	$(NVCC) -o tester.o main.cu seriale.o matrix_generator.o 
	./tester.o


run_test: SerialeDemo.c
	$(CC) -o SerialeDemo SerialeDemo.c 
	./SerialeDemo ./test/test1.txt
	./SerialeDemo ./test/test2.txt
	./SerialeDemo ./test/test3.txt


clean:
	clean:
	rm -f *.o $(TARGETS)


