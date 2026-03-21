#ifndef PARALLEL4_H
#define PARALLEL4_H
#include <stdint.h>  
#include <stdbool.h> 

inline uint8_t getBit(uint32_t* matrix, int row, int col, int numWords);
inline void toggleBit(uint32_t* matrix, int row, int col, int numWords);
__device__ __forceinline__ uint8_t getBitDevice(uint32_t* matrix, int row, int col, int numWords);
__global__ void findPivotKernel4(uint32_t* matrix, int n, int numWords, int col, int startRow, int* pivot);
__global__ void swapRowsKernel4(uint32_t* matrix, int numWords, int r1, int r2);
__global__ void eliminateKernel(uint32_t* matrix, int n, int numWords, int pivotRow, int pivotCol);
__global__ void gaussianEliminationKernel4(uint32_t* matrix, int n, int k);
bool gaussianEliminationCuda4(uint32_t* h_matrix, int n, int k, uint8_t* solution);

#endif