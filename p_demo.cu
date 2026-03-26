#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <vector>
#include "parallel1.h"
#include "parallel2.h"
#include "parallel3.h"
//#include "parallel4.h"
//#include "parallel5.h"

int main(int argc, char* argv[])
{
    if (argc < 3)
    {
        printf("Uso: %s <file_input>\n", argv[0]);
        return 1;
    }
    char *input_string = argv[2];
    printf("Stringa ricevuta: %s\n", input_string);

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

    if(strcmp(input_string, "p1") == 0){
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

    if(strcmp(input_string, "p2") == 0){
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

        bool ok = gaussianEliminationCuda2(matrix.data(), n, k, solution.data());

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

    if(strcmp(input_string, "p3") == 0){
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
    if(strcmp(input_string, "p4") == 0){
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

        bool ok = gaussianEliminationCuda4(matrix.data(), n, k, solution.data());

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
    /*if(strcmp(input_string, "p5") == 0){
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

        bool ok = gaussianEliminationCuda5(matrix.data(), n, k, solution.data());

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
    }*/

}