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

// Accesso ai bit
inline uint8_t getBit4(uint32_t* matrix, int row, int col, int numWords)
{
    int word = col / WORD_SIZE;
    int bit = col % WORD_SIZE;
    return (matrix[row*numWords + word] >> bit) & 1; //controllo se un determinato bit è 1 
}


__global__ void increaseRank4(int* rank){
    (*rank)++;
}

__global__ void eliminationKernel4(uint32_t* matrix, int n, int numWords,
                                 int* pivotRow, int pivotCol, int k)
{
    extern __shared__ uint32_t s_pivot[];

    int tx = threadIdx.x; // word index
    int ty = blockIdx.x;  // row index

    int row = ty;


    if(blockIdx.x * blockDim.x + threadIdx.x == 0    ){
            increaseRank4<<<1,1,0, cudaStreamTailLaunch>>>(pivotRow);
        }
    if (row <= *pivotRow || row >= n) return;


    int word = pivotCol / WORD_SIZE;
    int bit  = pivotCol % WORD_SIZE;

    // 🔹 carico pivot row in shared memory (cooperativo)
    for (int w = tx; w < numWords; w += blockDim.x) {
        s_pivot[w] = matrix[*pivotRow * numWords + w];
    }

    __syncthreads();

    // 🔹 controllo pivot bit (solo un thread per riga)
    __shared__ int active;
    if (tx == 0) {
        active = (matrix[row*numWords + word] >> bit) & 1;
    }
    __syncthreads();

    if (!active) return;

    // 🔹 ogni thread lavora su UNA word
    for (int w = tx; w < numWords; w += blockDim.x) {
        matrix[row*numWords + w] ^= s_pivot[w];
    }

}



__global__ void eliminationKernel44(uint32_t* matrix, int n, int numWords,
                                 int* pivotRow, int pivotCol)
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

    int word = pivotCol / WORD_SIZE;
    int bit = pivotCol % WORD_SIZE;

    for (int row = tid; row < n; row += stride) {
        if (row <= *pivotRow) continue;

        if ((matrix[row*numWords + word] >> bit) & 1) {
            for (int w = 0; w < numWords; w++) {
                matrix[row*numWords + w] ^= matrix[(*pivotRow)*numWords + w];
            }
        }
        
    }
    if(tid==0){
            increaseRank4<<<1,1,0, cudaStreamTailLaunch>>>(pivotRow);
        }

}

__global__ void swapRowsKernel4(uint32_t* matrix, int numWords,
                              int* rank, int pivot, int n, int col, int k)
{
    if(pivot == n){return;}

    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

    for (int w = tid; w < numWords; w += stride) {
        uint32_t tmp = matrix[*rank*numWords + w];
        matrix[*rank*numWords + w] = matrix[pivot*numWords + w];
        matrix[pivot*numWords + w] = tmp;
    }

    if (tid == 0) {
        int threads = 256;
        int blocks = (n + threads - 1) / threads;
        size_t sharedMemSize = numWords * sizeof(uint32_t);
        eliminationKernel4<<<n, threads, sharedMemSize,cudaStreamTailLaunch>>>(matrix, n, numWords, rank, col, k);//eliminationKernel4<<<blocks, threads, 0, cudaStreamTailLaunch>>>(matrix, n, numWords, rank, col);
        
        }
}

__global__ void findPivotKernel4(uint32_t* matrix, int n, int numWords,
                               int col, int* rank, int* pivot, int b, int t, int k)
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

    int word = col / WORD_SIZE;
    int bit = col % WORD_SIZE;

    for (int row = tid; row < n; row += stride) {
        if (row < *rank) continue;

        if ((matrix[row*numWords + word] >> bit) & 1) {
            atomicMin(pivot, row);
        }
    }

    if (blockIdx.x == 0 && threadIdx.x == 0) {
        swapRowsKernel4<<<b, t, 0, cudaStreamTailLaunch>>>(
            matrix, numWords, rank, *pivot, n, col, k);
    }
}

__global__ void resetPivot4(uint32_t* matrix, int n, int numWords,
                               int col, int* rank, int* pivot, int b, int t, int blocks, int k)
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    *pivot = n; 
   
   if(tid ==0){
     findPivotKernel4<<<blocks, t, 0, cudaStreamTailLaunch>>>(matrix, n, numWords, col, rank, pivot, b, t, k);
   }
}

// KERNEL CUDA: elimina righe sotto il pivot


bool gaussianEliminationCuda4(uint32_t* h_matrix, int n, int k, uint8_t* solution)
{
    int vars = k - 1;
    int rank = 0;
    int numWords = (k + WORD_SIZE - 1) / WORD_SIZE;

    uint32_t* d_matrix;
    int* d_pivot;
    int* d_rank; 

    cudaMalloc(&d_matrix, n * numWords * sizeof(uint32_t));
    cudaMalloc(&d_pivot, sizeof(int));
    cudaMalloc(&d_rank, sizeof(int));


    cudaMemcpy(d_matrix, h_matrix, n * numWords * sizeof(uint32_t), cudaMemcpyHostToDevice);
    cudaMemcpy(d_rank, &rank, sizeof(uint32_t), cudaMemcpyHostToDevice);

    int t = 256;
    int blocks = (n + t - 1) / t;
    int b = (numWords + t - 1) / t;
    int INF = n;
    cudaMemcpy(d_pivot, &INF, sizeof(int), cudaMemcpyHostToDevice);

    

    for (int col = 0; col < vars && rank < n; col++)
    {
        
       resetPivot4<<<1,1>>>(d_matrix, n, numWords, col, d_rank, d_pivot, b, t, blocks, k);
       cudaDeviceSynchronize();
       
    }

    cudaMemcpy(&rank, d_rank, sizeof(int), cudaMemcpyDeviceToHost);
    // copia finale UNA SOLA VOLTA
    cudaMemcpy(h_matrix, d_matrix, n*numWords*sizeof(uint32_t), cudaMemcpyDeviceToHost);



    cudaFree(d_pivot);
    cudaFree(d_rank);


    // controllo se il sistema è risolvibile 
    for (int row = rank; row < n; row++) {
        if (getBit4(h_matrix, row, vars, numWords)) {
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
            if (getBit4(h_matrix, i, j, numWords))
            {
                pivotCol = j;
                break;
            }
        }

        if (pivotCol == -1)
            continue;

        solution[pivotCol] = getBit4(h_matrix, i, vars, numWords);

        for (int j = pivotCol + 1; j < vars; j++)
        {
            if (getBit4(h_matrix, i, j, numWords))
                solution[pivotCol] ^= solution[j];
        }
    }

    cudaFree(d_matrix);
    return true;
}