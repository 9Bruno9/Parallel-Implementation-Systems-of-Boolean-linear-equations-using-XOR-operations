#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>
#include <string.h>
#include <stdint.h>
#include <vector>

#include "seriale.h"
#include "matrix_generator.h"

#include "parallel1.h"
#include "parallel2.h"
#include "parallel3.h"
#include "parallel4.h"
#include "parallel5.h"

#define N_TRY 20
#define CONTROL true



bool check_solution_bool(bool **matrix, int n, int k, bool *solution) {
    for (int i = 0; i < n; i++) {
        bool sum = 0;

        for (int j = 0; j < k-1; j++) {
            sum ^= (matrix[i][j] & solution[j]);  // XOR mod 2
        }

        if (sum != matrix[i][k-1]) {
            return false;  // errore trovato
        }
    }
    return true;  // tutto ok
}

bool check_solution_p1(uint8_t *matrix, int n, int k, uint8_t *solution) {
    for (int i = 0; i < n; i++) {
        uint8_t sum = 0;

        for (int j = 0; j < k - 1; j++) {
            sum ^= (matrix[i * k + j] & solution[j]);  // mod 2
        }

        if (sum != matrix[i * k + (k - 1)]) {
            return false;
        }
    }
    return true;
}



bool check_solution_packed(uint32_t *matrix, int n, int k, uint8_t *solution) {
    int numWords = (k + 31) / 32;

    for (int i = 0; i < n; i++) {
        int parity = 0;

        for (int w = 0; w < numWords; w++) {
            uint32_t row = matrix[i * numWords + w];
            uint32_t sol_word = 0;

            for (int b = 0; b < 32; b++) {
                int j = w * 32 + b;
                if (j < k - 1 && solution[j]) {
                    sol_word |= (1u << b);
                }
            }

            parity ^= __builtin_popcount(row & sol_word) % 2;
        }

        int expected = (matrix[i * numWords + (k - 1) / 32] >> ((k - 1) % 32)) & 1;

        if (parity != expected)
            return false;
    }

    return true;
}


int main(int argc, char *argv[]) {
    
    if (argc < 2) {
        printf("Uso: %s <stringa>\n", argv[0]);
        return 1;
    }

    char *input_string = argv[1];
    printf("Stringa ricevuta: %s\n", input_string);

    // Apri il file CSV per scrivere i risultati
    FILE *csv_file = NULL;
    if(strcmp(input_string, "versione_seriale") == 0){
         csv_file = fopen("result_data/prova_seriale.csv", "w");
        if (!csv_file) {
            perror("Errore nell'apertura del file CSV");
            return 1;
        }
    }
    else if(strcmp(input_string, "versione_p1") == 0){
        csv_file = fopen("result_data/risultati_p1_01_20_3050.csv", "w");
        if (!csv_file) {
            perror("Errore nell'apertura del file CSV");
            return 1;
        }

    }
    else if(strcmp(input_string, "versione_p2") == 0){
        csv_file = fopen("result_data/risultati_p2_01_20_3050.csv", "w");
        if (!csv_file) {
            perror("Errore nell'apertura del file CSV");
            return 1;
        }

    }
    else if(strcmp(input_string, "versione_p3") == 0){
        csv_file = fopen("result_data/risultati_p3_01_20_3050.csv", "w");
        if (!csv_file) {
            perror("Errore nell'apertura del file CSV");
            return 1;
        }
    }
    else if(strcmp(input_string, "versione_p4") == 0){
        csv_file = fopen("result_data/risultati_p4_prova.csv", "w");
        if (!csv_file) {
            perror("Errore nell'apertura del file CSV");
            return 1;
        }
    }
    else if(strcmp(input_string, "versione_p5") == 0){
        csv_file = fopen("result_data/risultati_p5_01_20_3050.csv", "w");
        if (!csv_file) {
            perror("Errore nell'apertura del file CSV");
            return 1;
        }
    }
    else return 1;

    double theta = 0.6;

    // Scrivi l'intestazione del file CSV
    fprintf(csv_file, "n,k,theta,tempo_esecuzione, result\n");

    // Definisci i range per n e k
    
    int n_values[N_TRY];
    for(int i=0; i<N_TRY; i++){
        n_values[i]= 512*(i+1);
    }

    clock_t start;
    clock_t end;
    bool result; 
    double tempo_esecuzione;
    // Cicla su diversi valori di n e k
    for (int i = 0; i < sizeof(n_values)/sizeof(n_values[0]); i++) {
      //  for (int j = 0; j < sizeof(k_values)/sizeof(k_values[0]); j++) {
            int n = n_values[i];
            int k = n_values[i];


            for(int z = 0; z<1; z++){
                // Alloca la matrice
                bool **matrix = (bool **)malloc(n * sizeof(bool *));
                for (int x = 0; x < n; x++) {
                    matrix[x] = (bool *)malloc(k * sizeof(bool));
                }

                // Genera la matrice
                matrix_generator(n, k, theta, matrix);

                // Misura il tempo di esecuzione
                
                if(strcmp(input_string, "versione_seriale") == 0){
                    bool *solution = (bool *)malloc((k-1) * sizeof(bool));
                    start = clock();
                    result = gaussianElimination(n, k, matrix, solution);
                    end = clock();
                    tempo_esecuzione = ((double)(end - start)) / CLOCKS_PER_SEC;

                    // Scrivi i risultati sul file CSV
                    if(CONTROL == false){ fprintf(csv_file, "%d,%d,%f,%f,%d\n", n, k, theta, tempo_esecuzione, result);}

                    if(CONTROL){
                        bool check = true;

                        if (result) {
                            check = check_solution_bool(matrix, n, k, solution);
                        } else {
                            // sistema dichiarato non risolvibile → check "non applicabile"
                            check = true;  // oppure usa -1 nel CSV
                        }

                        printf("Check: %s\n", check ? "OK" : "ERRORE");
                        fprintf(csv_file, "%d,%d,%f,%f,%d,%d\n", n, k, theta, tempo_esecuzione, result, check);
                    }
                    

                    printf("n=%d, k=%d, theta=%f, Tempo: %f secondi, Risultato: %d\n", n, k, theta, tempo_esecuzione, result);
                    free(solution);
                }
                else if(strcmp(input_string, "versione_p1") == 0){
                    uint8_t *h_matrix = (uint8_t *)malloc(n * k * sizeof(uint8_t));
                    for (int i = 0; i < n; i++)
                        for (int j = 0; j < k; j++)
                            h_matrix[i * k + j] = matrix[i][j];  // copia riga per riga
                    uint8_t *solution = (uint8_t *)malloc((k-1) * sizeof(uint8_t));

                    start = clock();
                    result = gaussianEliminationCuda1(h_matrix, n, k, solution);
                    end = clock();
                    tempo_esecuzione = ((double)(end - start)) / CLOCKS_PER_SEC;
                    
                    if(CONTROL == false){ fprintf(csv_file, "%d,%d,%f,%f,%d\n", n, k, theta, tempo_esecuzione, result);}

                    if(CONTROL){
                        bool check = true;

                        if (result) {
                            check = check_solution_p1(h_matrix, n, k, solution);
                        } else {
                            // sistema dichiarato non risolvibile → check "non applicabile"
                            check = true;  // oppure usa -1 nel CSV
                        }

                        
                        printf("Check: %s\n", check ? "OK" : "ERRORE");
                        fprintf(csv_file, "%d,%d,%f,%f,%d,%d\n", n, k, theta, tempo_esecuzione, result, check);
                    }
                    free(solution);
                    free(h_matrix);
                    
                    
                    printf("n=%d, k=%d, theta=%f, Tempo: %f secondi, Risultato: %d\n", n, k, theta, tempo_esecuzione, result);
                }
                else if(strcmp(input_string, "versione_p2") == 0){
                    
                    int numWords = (k + 31) / 32;

                    uint32_t *h_matrix = (uint32_t *)malloc(n * numWords * sizeof(uint32_t));
                    memset(h_matrix, 0, n * numWords * sizeof(uint32_t));


                    for (int i = 0; i < n; i++) {
                        for (int j = 0; j < k; j++) {
                            if (matrix[i][j]) {
                                int word = j / 32;
                                int bit = j % 32;
                                h_matrix[i * numWords + word] |= (1u << bit);
                            }
                        }
                    }
                    
                    uint8_t *solution = (uint8_t *)malloc((k-1) * sizeof(uint8_t));

                    start = clock();
                    result = gaussianEliminationCuda2(h_matrix, n, k, solution);
                    end = clock();
                    tempo_esecuzione = ((double)(end - start)) / CLOCKS_PER_SEC;
                    
                    if(CONTROL == false){ fprintf(csv_file, "%d,%d,%f,%f,%d\n", n, k, theta, tempo_esecuzione, result);}

                    if(CONTROL){
                        bool check = true;

                        if (result) {
                            check = check_solution_packed(h_matrix, n, k, solution);
                        } else {
                            // sistema dichiarato non risolvibile → check "non applicabile"
                            check = true;  // oppure usa -1 nel CSV
                        }

                        printf("Check: %s\n", check ? "OK" : "ERRORE");
                        fprintf(csv_file, "%d,%d,%f,%f,%d,%d\n", n, k, theta, tempo_esecuzione, result, check);
                    }

                    free(solution);
                    free(h_matrix);
                    
                    
                    printf("n=%d, k=%d, theta=%f, Tempo: %f secondi, Risultato: %d\n", n, k, theta, tempo_esecuzione, result);
                }
                else if(strcmp(input_string, "versione_p3") == 0){
                    
                    int numWords = (k + 31) / 32;

                    uint32_t *h_matrix = (uint32_t *)malloc(n * numWords * sizeof(uint32_t));
                    memset(h_matrix, 0, n * numWords * sizeof(uint32_t));


                    for (int i = 0; i < n; i++) {
                        for (int j = 0; j < k; j++) {
                            if (matrix[i][j]) {
                                int word = j / 32;
                                int bit = j % 32;
                                h_matrix[i * numWords + word] |= (1u << bit);
                            }
                        }
                    }
                    
                    uint8_t *solution = (uint8_t *)malloc((k-1) * sizeof(uint8_t));

                    start = clock();
                    result = gaussianEliminationCuda3(h_matrix, n, k, solution);
                    end = clock();
                    tempo_esecuzione = ((double)(end - start)) / CLOCKS_PER_SEC;
                    
                    if(CONTROL == false){ fprintf(csv_file, "%d,%d,%f,%f,%d\n", n, k, theta, tempo_esecuzione, result);}

                    if(CONTROL){
                        bool check = true;

                        if (result) {
                            check = check_solution_packed(h_matrix, n, k, solution);
                        } else {
                            // sistema dichiarato non risolvibile → check "non applicabile"
                            check = true;  // oppure usa -1 nel CSV
                        }

                        printf("Check: %s\n", check ? "OK" : "ERRORE");
                        fprintf(csv_file, "%d,%d,%f,%f,%d,%d\n", n, k, theta, tempo_esecuzione, result, check);
                    }
                    free(solution);
                    free(h_matrix);
                    
                    
                    printf("n=%d, k=%d, theta=%f, Tempo: %f secondi, Risultato: %d\n", n, k, theta, tempo_esecuzione, result);
                }
                else if(strcmp(input_string, "versione_p4") == 0){
                            
                            int numWords = (k + 31) / 32;

                            uint32_t *h_matrix = (uint32_t *)malloc(n * numWords * sizeof(uint32_t));
                            memset(h_matrix, 0, n * numWords * sizeof(uint32_t));


                            for (int i = 0; i < n; i++) {
                                for (int j = 0; j < k; j++) {
                                    if (matrix[i][j]) {
                                        int word = j / 32;
                                        int bit = j % 32;
                                        h_matrix[i * numWords + word] |= (1u << bit);
                                    }
                                }
                            }
                            
                            uint8_t *solution = (uint8_t *)malloc((k-1) * sizeof(uint8_t));

                            start = clock();
                            result = gaussianEliminationCuda4(h_matrix, n, k, solution);
                            end = clock();
                            tempo_esecuzione = ((double)(end - start)) / CLOCKS_PER_SEC;
                            
                            // Scrivi i risultati sul file CSV
                           if(CONTROL == false){ fprintf(csv_file, "%d,%d,%f,%f,%d\n", n, k, theta, tempo_esecuzione, result);}

                            if(CONTROL){
                                bool check = true;

                                if (result) {
                                    check = check_solution_packed(h_matrix, n, k, solution);
                                } else {
                                    // sistema dichiarato non risolvibile → check "non applicabile"
                                    check = true;  // oppure usa -1 nel CSV
                                }
                                printf("Check: %s\n", check ? "OK" : "ERRORE");
                                fprintf(csv_file, "%d,%d,%f,%f,%d,%d\n", n, k, theta, tempo_esecuzione, result, check);
                            }
                            free(solution);
                            free(h_matrix);
                            
                            
                            printf("n=%d, k=%d, theta=%f, Tempo: %f secondi, Risultato: %d\n", n, k, theta, tempo_esecuzione, result);
                }
                else if(strcmp(input_string, "versione_p5") == 0){
                            
                            int numWords = (k + 31) / 32;

                            uint32_t *h_matrix = (uint32_t *)malloc(n * numWords * sizeof(uint32_t));
                            memset(h_matrix, 0, n * numWords * sizeof(uint32_t));


                            for (int i = 0; i < n; i++) {
                                for (int j = 0; j < k; j++) {
                                    if (matrix[i][j]) {
                                        int word = j / 32;
                                        int bit = j % 32;
                                        h_matrix[i * numWords + word] |= (1u << bit);
                                    }
                                }
                            }
                            
                            uint8_t *solution = (uint8_t *)malloc((k-1) * sizeof(uint8_t));

                            start = clock();
                            result = gaussianEliminationCuda5(h_matrix, n, k, solution);
                            end = clock();
                            tempo_esecuzione = ((double)(end - start)) / CLOCKS_PER_SEC;
                            
                            // Scrivi i risultati sul file CSV
                            if(CONTROL == false){ fprintf(csv_file, "%d,%d,%f,%f,%d\n", n, k, theta, tempo_esecuzione, result);}

                            if(CONTROL){
                                bool check = true;

                                if (result) {
                                    check = check_solution_packed(h_matrix, n, k, solution);
                                } else {
                                    // sistema dichiarato non risolvibile → check "non applicabile"
                                    check = true;  // oppure usa -1 nel CSV
                                }

                                printf("Check: %s\n", check ? "OK" : "ERRORE");
                                fprintf(csv_file, "%d,%d,%f,%f,%d,%d\n", n, k, theta, tempo_esecuzione, result, check);
                            }
                            free(solution);
                            free(h_matrix);
                            
                            
                            printf("p5 n=%d, k=%d, theta=%f, Tempo: %f secondi, Risultato: %d\n", n, k, theta, tempo_esecuzione, result);
                }
                        for (int x = 0; x < n; x++)
                                free(matrix[x]);
                        free(matrix);
            }
        }

    // Chiudi il file CSV
    fclose(csv_file);

    return 0;
}

