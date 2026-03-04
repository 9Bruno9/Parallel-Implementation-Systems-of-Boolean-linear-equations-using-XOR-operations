#ifndef PARALLEL1_H
#define PARALLEL1_H
#include <stdint.h>  
#include <stdbool.h> 

bool gaussianEliminationCuda1(uint8_t* h_matrix, int n, int k, uint8_t* solution);
__global__ void rowsElimination(uint8_t* matrix, int n,int k,int pivotRow,int pivotCol);

#endif