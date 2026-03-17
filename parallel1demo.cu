#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <vector>

#define CHECK(call) \
{ \
    cudaError_t err = call; \
    if (err != cudaSuccess) { \
        printf("CUDA Error: %s\n", cudaGetErrorString(err)); \
        exit(1); \
    } \
}


// KERNEL CUDA: elimina righe sotto il pivot
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

        if (pivot == -1) 
            continue;

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

        int threads = min((n + 32 -1)/32 ,1024);
        int blocks = (n + threads - 1) / threads;

        rowsElimination<<<blocks, threads>>>(d_matrix, n, k, rank, col);
        CHECK(cudaDeviceSynchronize());

        CHECK(cudaMemcpy(h_matrix, d_matrix, n*k*sizeof(uint8_t),cudaMemcpyDeviceToHost));
        rank++;
    }


    for (int row = rank; row < n; row++) {
        if (h_matrix[row*k+k-1]) {
            cudaFree(d_matrix); 
            return false; }
    }
    /*
    for (int i = rank; i < n; i++)
    {
        bool allZero = true;

        for (int j = 0; j < vars; j++)
        {
            if (h_matrix[i*k + j])
            {
                allZero = false;
                break;
            }
        }

        if (allZero && h_matrix[i*k + vars])
        {
            cudaFree(d_matrix);
            return false;
        }
    }*/

    // Back substitution (CPU)

    for (int i = 0; i < vars; i++)
        solution[i] = 0;

    for (int i = rank - 1; i >= 0; i--)
    {
        int pivotCol = -1;

        for (int j = 0; j < vars; j++)
        {
            if (h_matrix[i*k + j])
            {
                pivotCol = j;
                break;
            }
        }

        if (pivotCol == -1)
            continue;

        solution[pivotCol] = h_matrix[i*k + vars];

        for (int j = pivotCol + 1; j < vars; j++)
        {
            if (h_matrix[i*k + j])
                solution[pivotCol] ^= solution[j];
        }
    }

    cudaFree(d_matrix);
    return true;
}


int main(int argc, char* argv[])
{
    if (argc < 2)
    {
        printf("Uso: %s <file_input>\n", argv[0]);
        return 1;
    }

    FILE* file = fopen(argv[1], "r");
    if (!file)
    {
        printf("Errore apertura file.\n");
        return 1;
    }

    int n = 0, k = 0;
    char line[2048];

    while (fgets(line, sizeof(line), file))
    {
        int count = 0;
        char* tok = strtok(line, " \t\n");
        while (tok)
        {
            count++;
            tok = strtok(NULL, " \t\n");
        }

        if (count > 0)
        {
            if (k == 0)
                k = count;
            n++;
        }
    }

    rewind(file);

    std::vector<uint8_t> matrix(n*k);
    std::vector<uint8_t> solution(k-1);

    for (int i = 0; i < n; i++)
        for (int j = 0; j < k; j++)
        {
            int val;
            fscanf(file, "%d", &val);
            matrix[i*k + j] = (uint8_t)val;
        }

    fclose(file);

    bool ok = gaussianEliminationCuda1(matrix.data(), n, k, solution.data());

    if (!ok)
    {
        printf("Sistema irrisolvibile.\n");
    }
    else
    {
        printf("Sistema risolvibile.\n");
        printf("Soluzione:\n");
        for (int i = 0; i < k-1; i++)
            printf("x%d = %d\n", i+1, solution[i]);
    }



    return 0;
}