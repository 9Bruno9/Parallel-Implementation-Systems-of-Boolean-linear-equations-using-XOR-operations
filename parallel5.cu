#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <vector>
#include "parallel5.h"

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
inline uint8_t getBit5(uint32_t* matrix, int row, int col, int numWords)
{
    int word = col / WORD_SIZE;
    int bit = col % WORD_SIZE;
    return (matrix[row*numWords + word] >> bit) & 1; //controllo se un determinato bit è 1 
}

__global__ void findPivotKernel5(uint32_t* matrix, int n, int numWords,
                               int col, int startRow, int* pivot)
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

    int word = col / WORD_SIZE;
    int bit = col % WORD_SIZE;

    for (int row = tid; row < n; row += stride) {
        if (row < startRow) continue;

        if ((matrix[row*numWords + word] >> bit) & 1) {
            atomicMin(pivot, row);
        }
    }
}

__global__ void swapRowsKernel5(uint32_t* matrix, int numWords,
                              int row1, int row2)
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

    for (int w = tid; w < numWords; w += stride) {
        uint32_t tmp = matrix[row1*numWords + w];
        matrix[row1*numWords + w] = matrix[row2*numWords + w];
        matrix[row2*numWords + w] = tmp;
    }
}

__global__ void eliminationKernel5(uint32_t* matrix, int n, int numWords,
                                 int pivotRow, int pivotCol)
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

    int word = pivotCol / WORD_SIZE;
    int bit = pivotCol % WORD_SIZE;

    for (int row = tid; row < n; row += stride) {
        if (row <= pivotRow) continue;

        if ((matrix[row*numWords + word] >> bit) & 1) {
            for (int w = 0; w < numWords; w++) {
                matrix[row*numWords + w] ^= matrix[pivotRow*numWords + w];
            }
        }
    }
}
// KERNEL CUDA: elimina righe sotto il pivot


bool gaussianEliminationCuda5(uint32_t* h_matrix, int n, int k, uint8_t* solution)
{
    int vars = k - 1;
    int rank = 0;
    int numWords = (k + WORD_SIZE - 1) / WORD_SIZE;

    uint32_t* d_matrix;
    int* d_pivot;

    cudaMalloc(&d_matrix, n * numWords * sizeof(uint32_t));
    cudaMalloc(&d_pivot, sizeof(int));

    cudaMemcpy(d_matrix, h_matrix, n * numWords * sizeof(uint32_t), cudaMemcpyHostToDevice);

    for (int col = 0; col < vars && rank < n; col++)
    {
        int INF = n;
        cudaMemcpy(d_pivot, &INF, sizeof(int), cudaMemcpyHostToDevice);

        // 1. FIND PIVOT
        int t = 256;
        int blocks = (n + t - 1) / t;

        findPivotKernel5<<<blocks, t>>>(d_matrix, n, numWords, col, rank, d_pivot);
        cudaDeviceSynchronize();

        int pivot;
        cudaMemcpy(&pivot, d_pivot, sizeof(int), cudaMemcpyDeviceToHost);
        if (pivot == n) continue;

        // 2. SWAP
        if (pivot != rank) {
            int b = (numWords + t - 1) / t;
            swapRowsKernel5<<<b, t>>>(d_matrix, numWords, rank, pivot);
            cudaDeviceSynchronize();
        }

        // 3. ELIMINATION
        eliminationKernel5<<<n, t>>>(d_matrix, n, numWords, rank, col);
        cudaDeviceSynchronize();

        rank++;
    }

    // copia finale UNA SOLA VOLTA
    cudaMemcpy(h_matrix, d_matrix, n*numWords*sizeof(uint32_t), cudaMemcpyDeviceToHost);

    cudaFree(d_matrix);
    cudaFree(d_pivot);

    // controllo se il sistema è risolvibile 
    for (int row = rank; row < n; row++) {
        if (getBit5(h_matrix, row, vars, numWords)) {
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
            if (getBit5(h_matrix, i, j, numWords))
            {
                pivotCol = j;
                break;
            }
        }

        if (pivotCol == -1)
            continue;

        solution[pivotCol] = getBit5(h_matrix, i, vars, numWords);

        for (int j = pivotCol + 1; j < vars; j++)
        {
            if (getBit5(h_matrix, i, j, numWords))
                solution[pivotCol] ^= solution[j];
        }
    }

    cudaFree(d_matrix);
    return true;
}