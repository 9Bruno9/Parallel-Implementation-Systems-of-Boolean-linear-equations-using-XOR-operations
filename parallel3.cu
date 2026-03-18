#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <vector>
#include "parallel3.h"

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
    return (matrix[row*numWords + word] >> bit) & 1; //controllo se un determinato bit è 1 
}

inline void toggleBit(uint32_t* matrix, int row, int col, int numWords)
{
    int word = col / WORD_SIZE;
    int bit = col % WORD_SIZE;
    matrix[row*numWords + word] ^= (1u << bit);
}


// KERNEL CUDA: elimina righe sotto il pivot
__global__ void rowsElimination3(
    uint32_t* matrix, int n, int numWords,
    int pivotRow, int pivotCol)
{
    extern __shared__ uint32_t pivotShared[];

    int tid = threadIdx.x;
    int globalRow = blockIdx.x * blockDim.x + tid;

    int wordStart = pivotCol / WORD_SIZE;

    // Carico pivot row in shared memory
    for (int w = tid; w < numWords; w += blockDim.x)
    {
        pivotShared[w] = matrix[pivotRow * numWords + w];
    }

    __syncthreads();

    // Elimino righe
    if (globalRow > pivotRow && globalRow < n)
    {
        int word = pivotCol / WORD_SIZE;
        int bit  = pivotCol % WORD_SIZE;

        if ((matrix[globalRow * numWords + word] >> bit) & 1) //controllo se un determinato bit è 1 
        {
            for (int w = wordStart; w < numWords; w++)
            {
                matrix[globalRow * numWords + w] ^= pivotShared[w];  
            }
        }
    }
}

bool gaussianEliminationCuda3(uint32_t* h_matrix, int n, int k, uint8_t* solution)
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

        

        int threads = min((n + 32 -1)/32 ,1024);
        int blocks = (n + threads - 1) / threads;

        size_t sharedSize = numWords * sizeof(uint32_t);

        rowsElimination3<<<blocks, threads, sharedSize>>>(d_matrix, n, numWords, rank, col);

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