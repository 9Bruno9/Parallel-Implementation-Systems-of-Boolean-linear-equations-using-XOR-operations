CC = gcc
NVCC = nvcc
TARGETS = tester SerialeDemo


main: main.cu seriale.c matrix_generator.c p_demo.cu
	gcc -c matrix_generator.c -o matrix_generator.o
	gcc -c seriale.c -o seriale.o
	nvcc -c  parallel1.cu -o parallel1.o
	nvcc -c  parallel2.cu -o parallel2.o
	nvcc -c  parallel3.cu -o parallel3.o
	$(NVCC) -o tester main.cu seriale.o matrix_generator.o parallel1.o parallel2.o parallel3.o
	$(NVCC) -o p_demo p_demo.cu parallel1.o parallel2.o parallel3.o
	
run_seriale: tester
	./tester versione_seriale	

run_par1: tester
	./tester versione_p1

run_par2: tester
	./tester versione_p2

run_par3: tester
	./tester versione_p3

all: tester
	./tester versione_seriale
	./tester versione_p1
	./tester versione_p2
	./tester versione_p3

run_test: SerialeDemo.c
	$(CC) -o SerialeDemo SerialeDemo.c seriale.o
	./SerialeDemo ./test/test1.txt
	./SerialeDemo ./test/test2.txt
	./SerialeDemo ./test/test3.txt
	./SerialeDemo ./test/test4.txt

demo_p1: p_demo.cu
	./p_demo ./test/test1.txt p1
	./p_demo ./test/test2.txt p1
	./p_demo ./test/test3.txt p1
	./p_demo ./test/test4.txt p1

demo_p2: p_demo.cu
	./p_demo ./test/test1.txt p2
	./p_demo ./test/test2.txt p2
	./p_demo ./test/test3.txt p2
	./p_demo ./test/test4.txt p2

demo_p3: p_demo.cu
	./p_demo ./test/test1.txt p3
	./p_demo ./test/test2.txt p3
	./p_demo ./test/test3.txt p3
	./p_demo ./test/test4.txt p3


clean:
	rm -f *.o $(TARGETS)


