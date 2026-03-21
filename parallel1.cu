#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <vector>
#include "parallel1.h"


#define CHECK(call) \
{ \
    cudaError_t err = call; \
    if (err != cudaSuccess) { \
        printf("CUDA Error: %s\n", cudaGetErrorString(err)); \
        exit(1); \
    } \
}


// elimina righe sotto il pivot, ogni thread si occupa di una riga ed eventualmente esegue XOR
__global__ void rowsElimination(uint8_t* matrix, int n,int k,int pivotRow,int pivotCol)
{
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    if (row > pivotRow && row < n) {
        if (matrix[row*k + pivotCol])
        {
            for (int j = pivotCol; j < k; j++)
                matrix[row*k + j] ^= matrix[pivotRow*k + j];
        }
    }
}

bool gaussianEliminationCuda1(uint8_t* h_matrix, int n, int k, uint8_t* solution)
{
    int vars = k - 1;
    int rank = 0;

    uint8_t* d_matrix;
    CHECK(cudaMalloc(&d_matrix, n*k*sizeof(uint8_t)));
    CHECK(cudaMemcpy(d_matrix, h_matrix, n*k*sizeof(uint8_t), cudaMemcpyHostToDevice));
    for (int col = 0; col < vars && rank < n; col++)
    {
        int pivot = -1;
        // Cerco pivot 
        for (int row = rank; row < n; row++)
        {
            if (h_matrix[row*k + col]){
                pivot = row;
                break;
            }
        }

        if (pivot == -1) {continue;}

        // Scambio righe 
        if (pivot != rank)
        {
            for (int j = 0; j < k; j++)
            {
                uint8_t tmp = h_matrix[rank*k + j];
                h_matrix[rank*k + j] = h_matrix[pivot*k + j];
                h_matrix[pivot*k + j] = tmp;
            }

            CHECK(cudaMemcpy(d_matrix, h_matrix, n*k*sizeof(uint8_t), cudaMemcpyHostToDevice));
        }

        int threads = 256;
        int blocks = (n + threads - 1) / threads;

        rowsElimination<<<blocks, threads>>>(d_matrix, n, k, rank, col);
        CHECK(cudaDeviceSynchronize());

        CHECK(cudaMemcpy(h_matrix, d_matrix, n*k*sizeof(uint8_t),cudaMemcpyDeviceToHost));
        rank++;
    }

    //controllo esistano soluzioni
    for (int row = rank; row < n; row++) {
        if (h_matrix[row*k+k-1]) {
            cudaFree(d_matrix); 
            return false; }
    }

    // Back substitution (CPU)

    for (int i = 0; i < vars; i++) {solution[i] = 0;}

    for (int i = rank - 1; i >= 0; i--)//scorro partendo dall'ultima riga non nulla
    {
        int pivotCol = -1;

        for (int j = 0; j < vars; j++) //scorro da x0 a xn finché non trovo un 1 
        {
            if (h_matrix[i*k + j])
            {
                pivotCol = j;
                break;
            }
        }

        if (pivotCol == -1)
            continue;

        solution[pivotCol] = h_matrix[i*k + vars]; //assegno al valore di quella pivot col il termine noto corrispondente

        for (int j = pivotCol + 1; j < vars; j++) //scorro tutte le altre variabili e se coeff==1 aggiungo il loro valore
        {
            if (h_matrix[i*k + j]) { solution[pivotCol] ^= solution[j];}
        }
    }

    cudaFree(d_matrix);
    return true;
}