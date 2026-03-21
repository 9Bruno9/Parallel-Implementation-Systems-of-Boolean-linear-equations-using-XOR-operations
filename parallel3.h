#ifndef PARALLEL3_H
#define PARALLEL3_H
#include <stdint.h>  
#include <stdbool.h> 

uint8_t getBit(uint32_t* matrix, int row, int col, int numWords);
void toggleBit(uint32_t* matrix, int row, int col, int numWords);
__global__ void eliminationKernel(uint32_t* matrix, int n, int numWords, int pivotRow, int pivotCol);
__global__ void swapRowsKernel(uint32_t* matrix, int numWords,int row1, int row2);
__global__ void findPivotKernel(uint32_t* matrix, int n, int numWords,int col, int startRow, int* pivot);
bool gaussianEliminationCuda3(uint32_t* h_matrix, int n, int k, uint8_t* solution);

#endif