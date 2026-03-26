#include <cuda_runtime.h>
#include <stdio.h>
#include <stdint.h>
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

// ================= BIT OPS =================
__device__ __host__
inline uint8_t getBit4(uint32_t* matrix, int row, int col, int numWords)
{
    int word = col / WORD_SIZE;
    int bit = col % WORD_SIZE;
    return (matrix[row*numWords + word] >> bit) & 1;
}

// ================= KERNELS FIGLI =================


#define WORD_SIZE 32

// 3. ELIMINATION
__global__ void eliminationKernel4(uint32_t* matrix, int n, int numWords,
                                 int pivotRow, int pivotCol)
{
    int row = blockIdx.x;
    int w   = threadIdx.x;

    if (row <= pivotRow || row >= n) return;
    if (w >= numWords) return;

    int word = pivotCol / WORD_SIZE;
    int bit  = pivotCol % WORD_SIZE;

    if ((matrix[row*numWords + word] >> bit) & 1) {
        matrix[row*numWords + w] ^= matrix[pivotRow*numWords + w];
    }
}
// 2. SWAP
__global__ void swapRowsKernel4(uint32_t* matrix, int numWords,
                              int rank, int* pivot,
                              int col, int n)
{
    int p = *pivot;

    // se non c'è pivot → salta tutto
    if (p == n) return;

    int w = threadIdx.x;

    if (p != rank && w < numWords)
    {
        uint32_t tmp = matrix[rank*numWords + w];
        matrix[rank*numWords + w] = matrix[p*numWords + w];
        matrix[p*numWords + w] = tmp;
    }

    __syncthreads();

    // launch elimination
    if (threadIdx.x == 0)
    {
        eliminationKernel4<<<n, numWords, 0, cudaStreamTailLaunch>>>(
            matrix, n, numWords, rank, col);
    }
}

// ================= FIND PIVOT =================
__global__ void findPivotKernel4(uint32_t* matrix, int n, int numWords,
                               int col, int startRow, int* pivot)
{
    int row = blockIdx.x * blockDim.x + threadIdx.x;

    if (row < startRow || row >= n) return;

    int word = col / WORD_SIZE;
    int bit  = col % WORD_SIZE;

    if ((matrix[row*numWords + word] >> bit) & 1) {
        atomicMin(pivot, row);
    }

    // SOLO 1 thread lancia il prossimo kernel
    if (threadIdx.x == 0 && blockIdx.x == 0)
    {
        swapRowsKernel4<<<1, 256, 0, cudaStreamTailLaunch>>>(
            matrix, numWords, startRow, pivot, col, n);
    }
}





// ================= KERNEL PADRE =================

__global__ void parentKernel4(uint32_t* matrix, int n, int numWords,
                            int col, int rank, int* pivot)
{
    if (threadIdx.x == 0 && blockIdx.x == 0)
    {
        *pivot = n;

        int threads = 256;
        int blocks  = (n + threads - 1) / threads;

        findPivotKernel4<<<blocks, threads, 0, cudaStreamTailLaunch>>>(
            matrix, n, numWords, col, rank, pivot);
    }
}

// ================= HOST =================

bool gaussianEliminationCuda4(uint32_t* h_matrix, int n, int k, uint8_t* solution)
{   
      int vars = k - 1;
    int rank = 0;
    int numWords = (k + WORD_SIZE - 1) / WORD_SIZE;

    uint32_t* d_matrix;
    int* d_pivot;

    cudaMalloc(&d_matrix, n * numWords * sizeof(uint32_t));
    cudaMalloc(&d_pivot, sizeof(int));

    cudaMemcpy(d_matrix, h_matrix,
               n * numWords * sizeof(uint32_t),
               cudaMemcpyHostToDevice);

    for (int col = 0; col < vars && rank < n; col++)
    {
        parentKernel4<<<1,1>>>(d_matrix, n, numWords, col, rank, d_pivot);

        // sincronizzazione globale tra iterazioni
        cudaDeviceSynchronize();

        int pivot;
        cudaMemcpy(&pivot, d_pivot, sizeof(int), cudaMemcpyDeviceToHost);

        if (pivot != n)
            rank++;
    }

    // ================= CHECK SOLUZIONE =================
    

      // controllo se il sistema è risolvibile 
    for (int row = rank; row < n; row++) {
        if (getBit4(h_matrix, row, vars, numWords)) {
            cudaFree(d_matrix); 
            return false; }
    }
   

    // ================= BACK SUBSTITUTION =================
    for (int i = 0; i < vars; i++)
        solution[i] = 0;

    for (int i = rank - 1; i >= 0; i--)
    {
        int pivotCol = -1;

        for (int j = 0; j < vars; j++)
        {
            if (getBit4(h_matrix, i, j, numWords)) {
                pivotCol = j;
                break;
            }
        }

        if (pivotCol == -1) continue;

        solution[pivotCol] = getBit4(h_matrix, i, vars, numWords);

        for (int j = pivotCol + 1; j < vars; j++)
            if (getBit4(h_matrix, i, j, numWords))
                solution[pivotCol] ^= solution[j];
    }

    cudaFree(d_matrix);
    cudaFree(d_pivot);

    return true;
}