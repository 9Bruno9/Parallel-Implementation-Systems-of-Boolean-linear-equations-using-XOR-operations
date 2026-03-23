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
// --- DEVICE UTILITIES ---
__device__ inline uint8_t getBitDevice(uint32_t* matrix, int row, int col, int numWords) {
    return (matrix[row * numWords + (col / WORD_SIZE)] >> (col % WORD_SIZE)) & 1;
}

// --- KERNELS ---

__global__ void findPivotKernel4(uint32_t* matrix, int n, int numWords, int col, int startRow, int* pivot) {
    int row = blockIdx.x * blockDim.x + threadIdx.x + startRow;
    if (row >= n) return;
    if (getBitDevice(matrix, row, col, numWords)) {
        atomicMin(pivot, row);
    }
}

__global__ void rowXorKernel(uint32_t* matrix, int n, int numWords, int pivotRow, int col, int startRow) {
    int r = blockIdx.x * blockDim.x + threadIdx.x + startRow;
    if (r >= n) return;

    // Ogni thread controlla la propria riga e decide se fare lo XOR
    if (getBitDevice(matrix, r, col, numWords)) {
        for (int w = 0; w < numWords; w++) {
            matrix[r * numWords + w] ^= matrix[pivotRow * numWords + w];
        }
    }
}

__global__ void swapAndEliminateKernel4(uint32_t* matrix, int n, int k, int numWords, int col, int* d_pivot, int* d_rank) {
    // Solo il primo thread del blocco gestisce la logica di controllo
    int pivotIdx = *d_pivot;
    int currentRank = *d_rank;
    int vars = k - 1;

    if (pivotIdx != n) {
        // --- SWAP PARALLELO ---
        // Usiamo tutti i thread del blocco per scambiare le parole della riga simultaneamente
        if (pivotIdx != currentRank) {
            for (int w = threadIdx.x; w < numWords; w += blockDim.x) {
                uint32_t tmp = matrix[currentRank * numWords + w];
                matrix[currentRank * numWords + w] = matrix[pivotIdx * numWords + w];
                matrix[pivotIdx * numWords + w] = tmp;
            }
        }
        __syncthreads(); // Aspettiamo che lo swap sia finito

        // --- ELIMINAZIONE PARALLELA ---
        // Solo il thread 0 lancia il kernel figlio per processare le righe rimanenti
        if (threadIdx.x == 0) {
            int startRowForElimination = currentRank + 1;
            int rowsToProcess = n - startRowForElimination;
            
            if (rowsToProcess > 0) {
                int threads = 256;
                int blocks = (rowsToProcess + threads - 1) / threads;
                // Lancio asincrono del figlio
                rowXorKernel<<<blocks, threads>>>(matrix, n, numWords, currentRank, col, startRowForElimination);
            }
            (*d_rank)++;
        }
    }
    __syncthreads(); // Sincronizzazione prima della ricorsione

    // --- PROSSIMA ITERAZIONE (RICORSIONE) ---
    if (threadIdx.x == 0) {
        int nextCol = col + 1;
        if (nextCol < vars && *d_rank < n) {
            *d_pivot = n; 
            int threads = 256;
            int blocks = (n - (*d_rank) + threads - 1) / threads;
            
            // Catena di lancio: Pivot -> Swap&Eliminate
            findPivotKernel4<<<blocks, threads>>>(matrix, n, numWords, nextCol, *d_rank, d_pivot);
            
            // NOTA: Il lancio di swapAndEliminate deve usare più thread ora!
            swapAndEliminateKernel4<<<1, 256>>>(matrix, n, k, numWords, nextCol, d_pivot, d_rank);
        }
    }
}

// --- HOST FUNCTION ---

bool gaussianEliminationCuda4(uint32_t* h_matrix, int n, int k, uint8_t* solution) {
    int vars = k - 1;
    int numWords = (k + WORD_SIZE - 1) / WORD_SIZE;

    uint32_t* d_matrix;
    int *d_pivot, *d_rank;
    int h_rank = 0;

    CHECK(cudaMalloc(&d_matrix, n * numWords * sizeof(uint32_t)));
    CHECK(cudaMalloc(&d_pivot, sizeof(int)));
    CHECK(cudaMalloc(&d_rank, sizeof(int)));

    CHECK(cudaMemcpy(d_matrix, h_matrix, n * numWords * sizeof(uint32_t), cudaMemcpyHostToDevice));
    
    int startPivot = n;
    CHECK(cudaMemcpy(d_pivot, &startPivot, sizeof(int), cudaMemcpyHostToDevice));
    CHECK(cudaMemcpy(d_rank, &h_rank, sizeof(int), cudaMemcpyHostToDevice));

    // Primo lancio: Trova il primo pivot e poi la catena prosegue da sola
    findPivotKernel4<<<(n + 255) / 256, 256>>>(d_matrix, n, numWords, 0, 0, d_pivot);
    swapAndEliminateKernel4<<<1, 1>>>(d_matrix, n, k, numWords, 0, d_pivot, d_rank);

    // Unica sincronizzazione lato HOST
    CHECK(cudaDeviceSynchronize());

    CHECK(cudaMemcpy(h_matrix, d_matrix, n * numWords * sizeof(uint32_t), cudaMemcpyDeviceToHost));
    CHECK(cudaMemcpy(&h_rank, d_rank, sizeof(int), cudaMemcpyDeviceToHost));

    // Controllo coerenza (CPU)
    for (int row = h_rank; row < n; row++) {
        int word = vars / WORD_SIZE;
        int bit = vars % WORD_SIZE;
        if ((h_matrix[row * numWords + word] >> bit) & 1) {
            cudaFree(d_matrix); cudaFree(d_pivot); cudaFree(d_rank);
            return false;
        }
    }

    // Back substitution (CPU)
    memset(solution, 0, vars);
    for (int i = h_rank - 1; i >= 0; i--) {
        int pivotCol = -1;
        for (int j = 0; j < vars; j++) {
            if ((h_matrix[i * numWords + (j / WORD_SIZE)] >> (j % WORD_SIZE)) & 1) {
                pivotCol = j; break;
            }
        }
        if (pivotCol == -1) continue;
        solution[pivotCol] = (h_matrix[i * numWords + (vars / WORD_SIZE)] >> (vars % WORD_SIZE)) & 1;
        for (int j = pivotCol + 1; j < vars; j++) {
            if ((h_matrix[i * numWords + (j / WORD_SIZE)] >> (j % WORD_SIZE)) & 1)
                solution[pivotCol] ^= solution[j];
        }
    }

    cudaFree(d_matrix); cudaFree(d_pivot); cudaFree(d_rank);
    return true;
}