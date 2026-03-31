#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <vector>
#include "parallel2.h"

#define WORD_SIZE 32

#define CHECK(call) \
{ \
    cudaError_t err = call; \
    if (err != cudaSuccess) { \
        printf("CUDA Error: %s\n", cudaGetErrorString(err)); \
        exit(1); \
    } \
}

// Accesso ai bit
inline uint8_t getBit(uint32_t* matrix, int row, int col, int numWords)
{
    int word = col / WORD_SIZE;
    int bit = col % WORD_SIZE;
    return (matrix[row*numWords + word] >> bit) & 1;
}

inline void toggleBit(uint32_t* matrix, int row, int col, int numWords)
{
    int word = col / WORD_SIZE;
    int bit = col % WORD_SIZE;
    matrix[row*numWords + word] ^= (1u << bit);
}


// KERNEL CUDA: elimina righe sotto il pivot
__global__ void rowsElimination2(uint32_t* matrix, int n, int numWords, int pivotRow, int pivotCol)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

    int word = pivotCol / WORD_SIZE;
    int bit  = pivotCol % WORD_SIZE;

    for (int row = idx; row < n; row += stride)
    {
        if (row > pivotRow)
        {
            if ((matrix[row * numWords + word] >> bit) & 1)
            {
                for (int w = word; w < numWords; w++)
                {
                    matrix[row * numWords + w] ^= matrix[pivotRow * numWords + w];
                }
            }
        }
    }
}

bool gaussianEliminationCuda2(uint32_t* h_matrix, int n, int k, uint8_t* solution)
{
    int vars = k - 1;
    int rank = 0;
    
    int numWords = (k + WORD_SIZE - 1) / WORD_SIZE;

    uint32_t* d_matrix;
    cudaMalloc(&d_matrix, n * numWords * sizeof(uint32_t));
    CHECK(cudaMemcpy(d_matrix, h_matrix, n*numWords*sizeof(uint32_t), cudaMemcpyHostToDevice));
    for (int col = 0; col < vars && rank < n; col++)
    {
        int pivot = -1;
        // Cerco pivot 
        for (int row = rank; row < n; row++)
        {
            if (getBit(h_matrix, row, col, numWords)){
                pivot = row;
                break;
            }
        }

        if (pivot == -1) 
            continue;

        // Scambio righe 
        if (pivot != rank)
        {
            for (int w = 0; w < numWords; w++)
            {
                uint32_t tmp = h_matrix[rank*numWords + w];
                h_matrix[rank*numWords + w] = h_matrix[pivot*numWords + w];
                h_matrix[pivot*numWords + w] = tmp;
            }

            CHECK(cudaMemcpy(d_matrix, h_matrix, n * numWords * sizeof(uint32_t), cudaMemcpyHostToDevice));
        }

        

        int threads = 256;
        int blocks = (n + threads - 1) / threads;

        rowsElimination2<<<blocks, threads>>>(d_matrix, n, numWords, rank, col);
        CHECK(cudaDeviceSynchronize());

        CHECK(cudaMemcpy(h_matrix, d_matrix, n*numWords*sizeof(uint32_t),cudaMemcpyDeviceToHost));
        rank++;
    }

    
    // controllo se il sistema è risolvibile 
    for (int row = rank; row < n; row++) {
        if (getBit(h_matrix, row, vars, numWords)) {
            cudaFree(d_matrix); 
            return false; }
    }
   

    // Back substitution (CPU)

    for (int i = 0; i < vars; i++)
        solution[i] = 0;

    for (int i = rank - 1; i >= 0; i--)
    {
        int pivotCol = -1;

        for (int j = 0; j < vars; j++)
        {
            if (getBit(h_matrix, i, j, numWords))
            {
                pivotCol = j;
                break;
            }
        }

        if (pivotCol == -1)
            continue;

        solution[pivotCol] = getBit(h_matrix, i, vars, numWords);

        for (int j = pivotCol + 1; j < vars; j++)
        {
            if (getBit(h_matrix, i, j, numWords))
                solution[pivotCol] ^= solution[j];
        }
    }

    cudaFree(d_matrix);
    return true;
}