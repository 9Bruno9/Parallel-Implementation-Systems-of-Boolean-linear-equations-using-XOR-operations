#ifndef PARALLEL4_H
#define PARALLEL4_H
#include <stdint.h>  
#include <stdbool.h> 



bool gaussianEliminationCuda4(uint32_t* h_matrix, int n, int k, uint8_t* solution);
#endif