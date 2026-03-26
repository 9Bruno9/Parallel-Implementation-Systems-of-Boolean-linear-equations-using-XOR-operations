#include <cuda_runtime.h>
#include <stdio.h>

#define N 10

// Terzo figlio: sottrae 1
__global__ void child3(float *data) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < N) {
        data[idx] -= 1.0f;
    }
}

// Secondo figlio: divide per 7 e lancia il terzo
__global__ void child2(float *data) {
   int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < N) {
        data[idx] *= 2.0f;
    }

    // Solo il primo thread lancia il kernel successivo in modalità "Tail Launch"
    if (idx == 0) {
        child3<<<2, 5, 0, cudaStreamTailLaunch>>>(data);
    }
}

// Primo figlio: aggiunge 5 e lancia il secondo
__global__ void child1(float *data) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < N) {
        data[idx] += 5.0f;
    }

    if (idx == 0) {
        child2<<<2, 5, 0, cudaStreamTailLaunch>>>(data);
    }
}

// Padre: lancia il primo figlio
__global__ void parent(float *data) {
    // Inizia la catena
    child1<<<2, 5, 0, cudaStreamTailLaunch>>>(data);
}

int main() {
    float *h_data = (float*)malloc(N * sizeof(float));
    float *d_data;

    // Inizializzazione vettore: tutti 10.0
    for (int i = 0; i < N; i++) h_data[i] = 10.0f;

    cudaMalloc(&d_data, N * sizeof(float));
    cudaMemcpy(d_data, h_data, N * sizeof(float), cudaMemcpyHostToDevice);

    printf("Esecuzione catena di kernel (Parent -> C1 -> C2 -> C3)...\n");
    for(int j=0; j <2; j++){
    // Lancio del padre
    parent<<<1, 1>>>(d_data);

    // Sincronizzazione e recupero dati
    cudaDeviceSynchronize();
    cudaMemcpy(h_data, d_data, N * sizeof(float), cudaMemcpyDeviceToHost);
    }
    // Verifica Risultato: ((10 + 5) / 7) - 1 = 1.1428
    printf("Risultato finale (primi 3 elementi):\n");
    for (int i = 0; i < 10; i++) {
        printf("Elemento [%d]: %f\n", i, h_data[i]);
    }

    cudaFree(d_data);
    free(h_data);

    return 0;
}