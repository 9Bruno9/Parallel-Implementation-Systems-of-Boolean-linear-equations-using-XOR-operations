CC = gcc
NVCC = nvcc
TARGETS = tester SerialeDemo


main: main.cu seriale.c matrix_generator.c
	gcc -c matrix_generator.c -o matrix_generator.o
	gcc -c seriale.c -o seriale.o
	$(NVCC) -o tester main.cu seriale.o matrix_generator.o 
	
run_seriale: tester
	./tester versione_seriale	





run_test: SerialeDemo.c
	$(CC) -o SerialeDemo SerialeDemo.c 
	./SerialeDemo ./test/test1.txt
	./SerialeDemo ./test/test2.txt
	./SerialeDemo ./test/test4.txt

run_test_CUDA1: parallel1demo.cu
	$(NVCC) -o parallel1demo parallel1demo.cu
	./parallel1demo ./test/test1.txt
	./parallel1demo ./test/test2.txt
	./parallel1demo ./test/test3.txt
	./parallel1demo ./test/test4.txt

clean:
	rm -f *.o $(TARGETS)


