#ifndef PARALLEL5_H
#define PARALLEL5_H
#include <stdint.h>  
#include <stdbool.h> 

inline uint8_t getBit5(uint32_t* matrix, int row, int col, int numWords);
inline void toggleBit5(uint32_t* matrix, int row, int col, int numWords);
bool gaussianEliminationCuda5(uint32_t* h_matrix, int n, int k, uint8_t* solution);


#endif