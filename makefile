CC      = gcc
NVCC    = nvcc

ARCH    = -arch=sm_86
NVFLAGS = $(ARCH) -rdc=true

TARGET  = tester
DEMO    = p_demo

# File sorgenti
C_SRCS  = seriale.c matrix_generator.c
CU_SRCS = parallel1.cu parallel2.cu parallel3.cu parallel4.cu parallel5.cu

# Object files
C_OBJS  = $(C_SRCS:.c=.o)
CU_OBJS = $(CU_SRCS:.cu=.o)

# Default
all: $(TARGET)

# Build tester
$(TARGET): main.cu $(C_OBJS) $(CU_OBJS)
	$(NVCC) $(NVFLAGS) -o $@ $^

# Build demo parallelo
$(DEMO): p_demo.cu $(CU_OBJS)
	$(NVCC) $(NVFLAGS) -o $@ $^

# Regole generiche
%.o: %.c
	$(CC) -c $< -o $@

%.o: %.cu
	$(NVCC) $(NVFLAGS) -c $< -o $@

# RUN
run_seriale: $(TARGET)
	./$(TARGET) versione_seriale

run_p%: $(TARGET)
	./$(TARGET) versione_p$*

# Demo seriale
demo_ser: SerialeDemo
	./SerialeDemo ./test/test1.txt
	./SerialeDemo ./test/test2.txt
	./SerialeDemo ./test/test3.txt
	./SerialeDemo ./test/test4.txt

SerialeDemo: SerialeDemo.c seriale.o
	$(CC) -o $@ $^

# Demo paralleli generici
demo_p%: $(DEMO)
	./$(DEMO) ./test/test1.txt p$*
	./$(DEMO) ./test/test2.txt p$*
	./$(DEMO) ./test/test3.txt p$*
	./$(DEMO) ./test/test4.txt p$*

# Clean
clean:
	rm -f *.o $(TARGET) $(DEMO) SerialeDemo prova

