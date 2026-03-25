#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

#define WORD_SIZE 32
#define CHECK(call) \
{ \
    cudaError_t err = call; \
    if (err != cudaSuccess) { \
        printf("CUDA Error: %s\n", cudaGetErrorString(err)); \
        exit(1); \
    } \
}

inline uint8_t getBit(uint32_t* matrix, int row, int col, int numWords) {
    int word = col / WORD_SIZE;
    int bit = col % WORD_SIZE;
    return (matrix[row * numWords + word] >> bit) & 1;
}

inline void toggleBit(uint32_t* matrix, int row, int col, int numWords) {
    int word = col / WORD_SIZE;
    int bit = col % WORD_SIZE;
    matrix[row * numWords + word] ^= (1u << bit);
}

// Kernel fuso: trova pivot, swap e elimina
__global__ void gaussianEliminationCuda4(
    uint32_t* matrix,
    int n,
    int numWords,
    int col,
    int rank,
    int* pivot,
    bool* foundPivot
) {
    extern __shared__ uint32_t sharedMatrix[];
    int row = blockIdx.x;
    int w = threadIdx.x;
    int pivotRow = *pivot;

    // Carica la riga corrente in shared memory
    if (row < n && w < numWords) {
        sharedMatrix[w] = matrix[row * numWords + w];
    }
    __syncthreads();

    // Trova il pivot (solo il primo thread del blocco)
    if (row >= rank && w == 0) {
        int word = col / WORD_SIZE;
        int bit = col % WORD_SIZE;
        if ((sharedMatrix[word] >> bit) & 1) {
            atomicMin(pivot, row);
            *foundPivot = true;
        }
    }
    __syncthreads();

    // Aggiorna pivotRow dopo atomicMin
    pivotRow = *pivot;

    // Swap delle righe (se necessario)
    if (pivotRow != rank && row == rank && w < numWords) {
        uint32_t tmp = sharedMatrix[w];
        sharedMatrix[w] = matrix[pivotRow * numWords + w];
        matrix[pivotRow * numWords + w] = tmp;
    }
    __syncthreads();

    // Elimina la colonna pivot nelle righe sottostanti
    if (row > rank && w < numWords) {
        int word = col / WORD_SIZE;
        int bit = col % WORD_SIZE;
        if ((sharedMatrix[word] >> bit) & 1) {
            sharedMatrix[w] ^= matrix[rank * numWords + w];
        }
    }
    __syncthreads();

    // Scrivi indietro in memoria globale
    if (row < n && w < numWords) {
        matrix[row * numWords + w] = sharedMatrix[w];
    }
}

bool gaussianEliminationCudaFused(
    uint32_t* h_matrix,
    int n,
    int k,
    uint8_t* solution
) {
    int vars = k - 1;
    int rank = 0;
    int numWords = (k + WORD_SIZE - 1) / WORD_SIZE;

    uint32_t* d_matrix;
    int* d_pivot;
    bool* d_foundPivot;
    bool h_foundPivot = false;

    CHECK(cudaMalloc(&d_matrix, n * numWords * sizeof(uint32_t)));
    CHECK(cudaMalloc(&d_pivot, sizeof(int)));
    CHECK(cudaMalloc(&d_foundPivot, sizeof(bool)));

    CHECK(cudaMemcpy(d_matrix, h_matrix, n * numWords * sizeof(uint32_t), cudaMemcpyHostToDevice));

    for (int col = 0; col < vars && rank < n; col++) {
        int INF = n;
        h_foundPivot = false;
        CHECK(cudaMemcpy(d_pivot, &INF, sizeof(int), cudaMemcpyHostToDevice));
        CHECK(cudaMemcpy(d_foundPivot, &h_foundPivot, sizeof(bool), cudaMemcpyHostToDevice));

        // Dimensione del blocco: 1 blocco per riga, 1 thread per word
        int threadsPerBlock = numWords;
        int blocksPerGrid = n;

        // Dimensione della shared memory: numWords * sizeof(uint32_t)
        size_t sharedMemSize = numWords * sizeof(uint32_t);

        gaussianEliminationCuda4<<<blocksPerGrid, threadsPerBlock, sharedMemSize>>>(
            d_matrix, n, numWords, col, rank, d_pivot, d_foundPivot
        );
        CHECK(cudaDeviceSynchronize());

        // Leggi il pivot trovato
        int pivot;
        CHECK(cudaMemcpy(&pivot, d_pivot, sizeof(int), cudaMemcpyDeviceToHost));
        CHECK(cudaMemcpy(&h_foundPivot, d_foundPivot, sizeof(bool), cudaMemcpyDeviceToHost));

        if (!h_foundPivot) continue;

        rank++;
    }

    // Copia finale della matrice
    CHECK(cudaMemcpy(h_matrix, d_matrix, n * numWords * sizeof(uint32_t), cudaMemcpyDeviceToHost));

    // Controllo risolvibilità (CPU)
    for (int row = rank; row < n; row++) {
        if (getBit(h_matrix, row, vars, numWords)) {
            CHECK(cudaFree(d_matrix));
            CHECK(cudaFree(d_pivot));
            CHECK(cudaFree(d_foundPivot));
            return false;
        }
    }

    // Back substitution (CPU)
    for (int i = 0; i < vars; i++) solution[i] = 0;
    for (int i = rank - 1; i >= 0; i--) {
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
            if (getBit(h_matrix, i, j, numWords)) {
                solution[pivotCol] ^= solution[j];
            }
        }
    }

    CHECK(cudaFree(d_matrix));
    CHECK(cudaFree(d_pivot));
    CHECK(cudaFree(d_foundPivot));

    return true;
}