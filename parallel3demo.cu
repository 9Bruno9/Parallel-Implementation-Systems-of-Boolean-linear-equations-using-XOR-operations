#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <vector>
#include "parallel3.h"


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

    int numWords = (k + 32 - 1) / 32;

    std::vector<uint32_t> matrix(n * numWords, 0);

    std::vector<uint8_t> solution(k-1);

    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < k; j++)
        {
            int val;
            fscanf(file, "%d", &val);

            if (val)
            {
                int word = j / 32;
                int bit  = j % 32;

                matrix[i*numWords + word] |= (1u << bit); //se 1 crea una word di 32 bit con l'1 nella posizione e poi fai un OR (addizione) alla word attuale per aggiungere quel bit in quella posizione
            }
        }
    }

    fclose(file);

    bool ok = gaussianEliminationCuda3(matrix.data(), n, k, solution.data());

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