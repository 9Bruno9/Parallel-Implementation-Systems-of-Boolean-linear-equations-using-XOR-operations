#include <cuda_runtime.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include "parallel4.h"
#define WORD_SIZE 32

#define CHECK(call) \
{ \
    cudaError_t err = call; \
    if (err != cudaSuccess) { \
        printf("CUDA Error: %s\n", cudaGetErrorString(err)); \
        exit(1); \
    } \
}

// Bit access CPU
inline uint8_t getBit(uint32_t* matrix, int row, int col, int numWords)
{
    int word = col / WORD_SIZE;
    int bit  = col % WORD_SIZE;
    return (matrix[row*numWords + word] >> bit) & 1;
}

// GPU bit access
__device__ __forceinline__ uint8_t getBitDevice(uint32_t* matrix, int row, int col, int numWords)
{
    int word = col / WORD_SIZE;
    int bit  = col % WORD_SIZE;
    return (matrix[row*numWords + word] >> bit) & 1;
}

// =================================
// findPivotKernel4
// Kernel figlio che cerca il pivot
// =================================
__global__ void findPivotKernel4(uint32_t* matrix, int n, int numWords, int col, int startRow, int* pivot)
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    int row = startRow + tid;
    if (row >= n) return;
    if (getBitDevice(matrix, row, col, numWords)) {
        atomicMin(pivot, row);
    }
}

// =================================
// swapRowsKernel4
// Scambia due righe
// =================================
__global__ void swapRowsKernel4(uint32_t* matrix, int numWords, int r1, int r2)
{
    int w = blockIdx.x * blockDim.x + threadIdx.x;
    if (w >= numWords) return;
    uint32_t tmp = matrix[r1*numWords + w];
    matrix[r1*numWords + w] = matrix[r2*numWords + w];
    matrix[r2*numWords + w] = tmp;
}

// =================================
// eliminateKernel
// Elimina sotto pivot
// =================================
__global__ void eliminateKernel(uint32_t* matrix, int n, int numWords, int pivotRow, int pivotCol)
{
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    if (row <= pivotRow || row >= n) return;

    int word = pivotCol / WORD_SIZE;
    int bit  = pivotCol % WORD_SIZE;

    if ((matrix[row*numWords + word] >> bit) & 1) {
        for (int w = word; w < numWords; w++)
            matrix[row*numWords + w] ^= matrix[pivotRow*numWords + w];
    }
}

// =================================
// gaussianEliminationKernel4
// Ker nel principale che usa dynamic parallelism
// =================================
__global__ void gaussianEliminationKernel4(uint32_t* matrix, int n, int k, int* pivotBuffer)
{
    int vars = k - 1;
    int numWords = (k + WORD_SIZE - 1) / WORD_SIZE;
    int rank = 0;

    for (int col = 0; col < vars && rank < n; col++)
    {
        // Init pivot
        pivotBuffer[0] = n;

        int threads = 256;
        int rowsToTest = n - rank;
        int blocks  = (rowsToTest + threads - 1) / threads;

        // Lancio findPivotKernel4 come kernel figlio
        findPivotKernel4<<<blocks, threads>>>(matrix, n, numWords, col, rank, pivotBuffer);

        // Non usare cudaDeviceSynchronize() qui dentro!
        // L’host sincronizzerà al ritorno del kernel principale.

        // Dopo il lancio, un thread nel kernel può proseguire
        __syncthreads(); // Solo tra threads nel grid locale
        int pivot = pivotBuffer[0];

        if (pivot == n) continue;

        // Scambia righe se serve
        if (pivot != rank)
        {
            int swapBlocks = (numWords + threads - 1) / threads;
            swapRowsKernel4<<<swapBlocks, threads>>>(matrix, numWords, rank, pivot);
            __syncthreads(); // sincronizza solo threads dei blocchi nella stessa grid
        }

        // Kernel figlio per eliminare
        eliminateKernel<<<blocks, threads>>>(matrix, n, numWords, rank, col);

        __syncthreads(); // sincronizza threads nella grid primaria

        rank++;
    }
}

// =================================
// Funzione host
// =================================
bool gaussianEliminationCuda4(uint32_t* h_matrix, int n, int k, uint8_t* solution)
{
    int numWords = (k + WORD_SIZE - 1) / WORD_SIZE;
    uint32_t* d_matrix;
    CHECK(cudaMalloc(&d_matrix, n * numWords * sizeof(uint32_t)));
    CHECK(cudaMemcpy(d_matrix, h_matrix, n*numWords*sizeof(uint32_t), cudaMemcpyHostToDevice));

    int* d_pivot;
    CHECK(cudaMalloc(&d_pivot, sizeof(int)));

    // Lancio kernel principale
    gaussianEliminationKernel4<<<1,1>>>(d_matrix, n, k, d_pivot);

    // Aspetta che tutto finisca
    CHECK(cudaDeviceSynchronize());

    // Riporta matrice su host
    CHECK(cudaMemcpy(h_matrix, d_matrix, n*numWords*sizeof(uint32_t), cudaMemcpyDeviceToHost));

    // Free
    cudaFree(d_matrix);
    cudaFree(d_pivot);

    // Back‑substitution su CPU (come nel tuo codice)
    int vars = k - 1;
    int rank = 0;
    for (int row = 0; row < n; row++)
    {
        bool nonZero = false;
        for (int col = 0; col < vars; col++)
        {
            if (getBit(h_matrix, row, col, numWords)) { nonZero = true; break; }
        }
        if (nonZero) rank++;
    }

    for (int row = rank; row < n; row++) {
        if (getBit(h_matrix, row, vars, numWords)) {
            return false;
        }
    }

    for (int i = 0; i < vars; i++) solution[i] = 0;
    for (int i = rank - 1; i >= 0; i--)
    {
        int pivotCol = -1;
        for (int j = 0; j < vars; j++)
        {
            if (getBit(h_matrix, i, j, numWords)) { pivotCol = j; break; }
        }
        if (pivotCol == -1) continue;

        solution[pivotCol] = getBit(h_matrix, i, vars, numWords);
        for (int j = pivotCol + 1; j < vars; j++)
            if (getBit(h_matrix, i, j, numWords))
                solution[pivotCol] ^= solution[j];
    }

    return true;
}