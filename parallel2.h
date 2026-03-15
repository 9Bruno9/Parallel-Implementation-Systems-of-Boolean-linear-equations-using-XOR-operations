#ifndef PARALLEL2_H
#define PARALLEL2_H
#include <stdint.h>  
#include <stdbool.h> 

uint8_t getBit(uint32_t* matrix, int row, int col, int numWords);
void toggleBit(uint32_t* matrix, int row, int col, int numWords);
__global__ void rowsElimination2(uint32_t* matrix, int n, int numWords, int pivotRow, int pivotCol);
bool gaussianEliminationCuda2(uint32_t* h_matrix, int n, int k, uint8_t* solution);

#endif