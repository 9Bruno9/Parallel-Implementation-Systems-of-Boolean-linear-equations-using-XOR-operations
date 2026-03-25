#ifndef PARALLEL4_H
#define PARALLEL4_H
#include <stdint.h>  
#include <stdbool.h> 

__device__ inline uint8_t getBitDevice(uint32_t* matrix, int row, int col, int numWords);

__global__ void gaussianEliminationCuda4(
    uint32_t* matrix,
    int n,
    int numWords,
    int col,
    int rank,
    int* pivot,
    bool* foundPivot
)
#endif