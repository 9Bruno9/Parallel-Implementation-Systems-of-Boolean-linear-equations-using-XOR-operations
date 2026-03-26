CC = gcc
NVCC = nvcc
TARGETS = tester SerialeDemo


main: main.cu seriale.c matrix_generator.c p_demo.cu
	gcc -c matrix_generator.c -o matrix_generator.o
	gcc -c seriale.c -o seriale.o
	nvcc -arch=sm_86 -rdc=true -c   parallel1.cu -o parallel1.o
	nvcc -arch=sm_86 -rdc=true -c   parallel2.cu -o parallel2.o
	nvcc -arch=sm_86 -rdc=true -c  parallel3.cu -o parallel3.o
	nvcc -arch=sm_86 -rdc=true -c  parallel4.cu -o parallel4.o
	#nvcc -arch=sm_86 -rdc=true -c  parallel5.cu -o parallel5.o
	$(NVCC) -arch=sm_86 -rdc=true -o tester main.cu seriale.o matrix_generator.o parallel1.o parallel2.o parallel3.o parallel4.o #parallel5.o
	$(NVCC) -arch=sm_86 -rdc=true -o p_demo p_demo.cu parallel1.o parallel2.o parallel3.o parallel4.o #parallel5.o
	
run_seriale: tester
	./tester versione_seriale	

run_p1: tester
	./tester versione_p1

run_p2: tester
	./tester versione_p2

run_p3: tester
	./tester versione_p3
run_p4: tester
	./tester versione_p4
run_p5: tester
	./tester versione_p5

all: tester
	./tester versione_seriale
	./tester versione_p1
	./tester versione_p2
	./tester versione_p3

demo_ser: SerialeDemo.c
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
	
demo_p4: p_demo.cu
	./p_demo ./test/test1.txt p4
	./p_demo ./test/test2.txt p4
	./p_demo ./test/test3.txt p4
	./p_demo ./test/test4.txt p4

demo_p5: p_demo.cu
	./p_demo ./test/test1.txt p5
	./p_demo ./test/test2.txt p5
	./p_demo ./test/test3.txt p5
	./p_demo ./test/test4.txt p5


clean:
	rm -f *.o $(TARGETS)


