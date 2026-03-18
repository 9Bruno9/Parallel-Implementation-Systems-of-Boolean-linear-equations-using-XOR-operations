#ifndef PARALLEL3_H
#define PARALLEL3_H
#include <stdint.h>  
#include <stdbool.h> 

uint8_t getBit(uint32_t* matrix, int row, int col, int numWords);
void toggleBit(uint32_t* matrix, int row, int col, int numWords);
__global__ void rowsElimination3(uint32_t* matrix, int n, int numWords, int pivotRow, int pivotCol);
bool gaussianEliminationCuda3(uint32_t* h_matrix, int n, int k, uint8_t* solution);

#endif