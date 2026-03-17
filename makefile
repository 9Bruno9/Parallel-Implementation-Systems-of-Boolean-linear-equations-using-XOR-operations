CC = gcc
NVCC = nvcc
TARGETS = tester SerialeDemo


main: main.cu seriale.c matrix_generator.c
	gcc -c matrix_generator.c -o matrix_generator.o
	gcc -c seriale.c -o seriale.o
	nvcc -c  parallel1.cu -o parallel1.o
	nvcc -c  parallel2.cu -o parallel2.o
	$(NVCC) -o tester main.cu seriale.o matrix_generator.o parallel1.o parallel2.o
	
run_seriale: tester
	./tester versione_seriale	

run_par1: tester
	./tester versione_p1

run_par2: tester
	./tester versione_p2

run_test: SerialeDemo.c
	$(CC) -o SerialeDemo SerialeDemo.c seriale.o
	./SerialeDemo ./test/test1.txt
	./SerialeDemo ./test/test2.txt
	./SerialeDemo ./test/test3.txt
	./SerialeDemo ./test/test4.txt

run_test_CUDA1: parallel1demo.cu
	$(NVCC) -o parallel1demo parallel1demo.cu parallel1.o
	./parallel1demo ./test/test1.txt
	./parallel1demo ./test/test2.txt
	./parallel1demo ./test/test3.txt
	./parallel1demo ./test/test4.txt

run_test_CUDA2: parallel2demo.cu
	$(NVCC) -o parallel2demo parallel2demo.cu parallel2.o
	./parallel2demo ./test/test1.txt
	./parallel2demo ./test/test2.txt
	./parallel2demo ./test/test3.txt
	./parallel2demo ./test/test4.txt


clean:
	rm -f *.o $(TARGETS)


