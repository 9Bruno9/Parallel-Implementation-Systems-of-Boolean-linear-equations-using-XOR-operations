TARGETS = tester SerialeDemo p_demo
TESTS = ./test/test1.txt ./test/test2.txt ./test/test3.txt ./test/test4.txt


main: main.cu seriale.c matrix_generator.c p_demo.cu SerialeDemo.c
	gcc -c matrix_generator.c -o matrix_generator.o
	gcc -c seriale.c -o seriale.o
	gcc -o SerialeDemo SerialeDemo.c seriale.o
	nvcc -arch=sm_86 -rdc=true -c   parallel1.cu -o parallel1.o
	nvcc -arch=sm_86 -rdc=true -c   parallel2.cu -o parallel2.o
	nvcc -arch=sm_86 -rdc=true -c  parallel3.cu -o parallel3.o
	nvcc -arch=sm_86 -rdc=true -c  parallel4.cu -o parallel4.o
	nvcc -arch=sm_86 -rdc=true -c  parallel5.cu -o parallel5.o
	nvcc -arch=sm_86 -rdc=true -o tester main.cu seriale.o matrix_generator.o parallel1.o parallel2.o parallel3.o parallel4.o parallel5.o
	nvcc -arch=sm_86 -rdc=true -o p_demo p_demo.cu parallel1.o parallel2.o parallel3.o parallel4.o parallel5.o
	
run_seriale: tester
	./tester versione_seriale	

run_p%: tester
	./tester versione_p$*

run_all: tester
	./tester versione_seriale
	./tester versione_p1
	./tester versione_p2
	./tester versione_p3
	./tester versione_p4
	./tester versione_p5

demo_p%: p_demo
	for t in $(TESTS); do \
		./p_demo $$t p$*; \
	done

demo_ser: p_demo
	for t in $(TESTS); do \
		./SerialeDemo $$t p$*; \
	done

clean:
	rm -f *.o $(TARGETS)
