#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <vector>
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

// --- UTILITY HOST ---
inline uint8_t getBit(uint32_t* matrix, int row, int col, int numWords)
{
    int word = col / WORD_SIZE;
    int bit = col % WORD_SIZE;
    return (matrix[row*numWords + word] >> bit) & 1;
}

// --- KERNELS FIGLI (Chiamati dal Master) ---

__global__ void findPivotKernel4(uint32_t* matrix, int n, int numWords, int col, int startRow, int* pivot)
{
    int row = blockIdx.x * blockDim.x + threadIdx.x + startRow;
    if (row >= n) return;

    int word = col / WORD_SIZE;
    int bit = col % WORD_SIZE;

    if ((matrix[row*numWords + word] >> bit) & 1) {
        atomicMin(pivot, row); 
    }
}

__global__ void swapRowsKernel4(uint32_t* matrix, int numWords, int row1, int row2)
{
    int w = threadIdx.x + blockIdx.x * blockDim.x;
    if (w < numWords) {
        uint32_t tmp = matrix[row1*numWords + w];
        matrix[row1*numWords + w] = matrix[row2*numWords + w];
        matrix[row2*numWords + w] = tmp;
    }
}

__global__ void eliminationKernel4(uint32_t* matrix, int n, int numWords, int pivotRow, int pivotCol)
{
    int row = blockIdx.x + pivotRow + 1; 
    int w = threadIdx.x;

    if (row >= n || w >= numWords) return;

    int word = pivotCol / WORD_SIZE;
    int bit = pivotCol % WORD_SIZE;

    if ((matrix[row*numWords + word] >> bit) & 1) {
        matrix[row*numWords + w] ^= matrix[pivotRow*numWords + w];
    }
}

// --- MASTER KERNEL ---
// Gestisce l'intera iterazione lato GPU
__global__ void gaussianMasterKernel4(uint32_t* matrix, int n, int k, int numWords, int* d_pivot, int* d_rank)
{
    int vars = k - 1;
    
    for (int col = 0; col < vars && *d_rank < n; col++)
    {
        // Init pivot per questa colonna
        *d_pivot = n;
        __threadfence(); 

        // 1. FIND PIVOT
        int threads = 256;
        int blocks = (n - *d_rank + threads - 1) / threads;
        findPivotKernel4<<<blocks, threads>>>(matrix, n, numWords, col, *d_rank, d_pivot);
        
        // Sincronizzazione necessaria per leggere il risultato di findPivot
        cudaDeviceSynchronize();

        int pivotIdx = *d_pivot;
        if (pivotIdx != n) {
            int currentRank = *d_rank;

            // 2. SWAP
            if (pivotIdx != currentRank) {
                int b_swap = (numWords + 255) / 256;
                swapRowsKernel4<<<b_swap, 256>>>(matrix, numWords, currentRank, pivotIdx);
            }

            // 3. ELIMINATION
            int rowsToProcess = n - currentRank - 1;
            if (rowsToProcess > 0) {
                // Lancio con griglia 1D per semplicità, ogni blocco gestisce una riga
                eliminationKernel4<<<rowsToProcess, numWords>>>(matrix, n, numWords, currentRank, col);
            }

            // Sincronizzazione implicita tra le iterazioni delle colonne
            cudaDeviceSynchronize();
            (*d_rank)++;
        }
    }
}

// --- FUNZIONE PRINCIPALE ---

bool gaussianEliminationCuda4(uint32_t* h_matrix, int n, int k, uint8_t* solution)
{
    int vars = k - 1;
    int numWords = (k + WORD_SIZE - 1) / WORD_SIZE;

    uint32_t* d_matrix;
    int *d_pivot, *d_rank;
    int h_rank = 0;

    CHECK(cudaMalloc(&d_matrix, n * numWords * sizeof(uint32_t)));
    CHECK(cudaMalloc(&d_pivot, sizeof(int)));
    CHECK(cudaMalloc(&d_rank, sizeof(int)));

    CHECK(cudaMemcpy(d_matrix, h_matrix, n * numWords * sizeof(uint32_t), cudaMemcpyHostToDevice));
    CHECK(cudaMemcpy(d_rank, &h_rank, sizeof(int), cudaMemcpyHostToDevice));

    // Singolo lancio per gestire tutto l'algoritmo
    gaussianMasterKernel4<<<1, 1>>>(d_matrix, n, k, numWords, d_pivot, d_rank);
    CHECK(cudaDeviceSynchronize());

    // Recupero dati e rank finale
    CHECK(cudaMemcpy(h_matrix, d_matrix, n * numWords * sizeof(uint32_t), cudaMemcpyDeviceToHost));
    CHECK(cudaMemcpy(&h_rank, d_rank, sizeof(int), cudaMemcpyDeviceToHost));

    // Controllo risolvibilità
    for (int row = h_rank; row < n; row++) {
        if (getBit(h_matrix, row, vars, numWords)) {
            cudaFree(d_matrix);
            cudaFree(d_pivot);
            cudaFree(d_rank);
            return false; 
        }
    }

    // Back substitution (CPU)
    for (int i = 0; i < vars; i++) solution[i] = 0;

    for (int i = h_rank - 1; i >= 0; i--)
    {
        int pivotCol = -1;
        for (int j = 0; j < vars; j++) {
            if (getBit(h_matrix, i, j, numWords)) {
                pivotCol = j;
                break;
            }
        }

        if (pivotCol == -1) continue;

        solution[pivotCol] = getBit(h_matrix, i, vars, numWords);
        for (int j = pivotCol + 1; j < vars; j++) {
            if (getBit(h_matrix, i, j, numWords))
                solution[pivotCol] ^= solution[j];
        }
    }

    cudaFree(d_matrix);
    cudaFree(d_pivot);
    cudaFree(d_rank);
    return true;
}