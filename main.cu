#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>
#include "seriale.h"
#include "matrix_generator.h"

int main() {
    // Apri il file CSV per scrivere i risultati
    FILE *csv_file = fopen("risultati_seriale.csv", "w");
    if (!csv_file) {
        perror("Errore nell'apertura del file CSV");
        return 1;
    }

    // Scrivi l'intestazione del file CSV
    fprintf(csv_file, "n,k,theta,tempo_esecuzione, result\n");

    // Definisci i range per n e k
    int n_values[] = {100, 200, 300, 400, 500};
    int k_values[] = {100, 200, 300, 400, 500};
    double theta = 0.5;

    // Cicla su diversi valori di n e k
    for (int i = 0; i < sizeof(n_values)/sizeof(n_values[0]); i++) {
        for (int j = 0; j < sizeof(k_values)/sizeof(k_values[0]); j++) {
            int n = n_values[i];
            int k = k_values[j];

            // Alloca la matrice
            bool **matrix = (bool **)malloc(n * sizeof(bool *));
            for (int x = 0; x < n; x++) {
                matrix[x] = (bool *)malloc(k * sizeof(bool));
            }

            // Genera la matrice
            srand(42);
            matrix_generator(n, k, theta, matrix);

            // Misura il tempo di esecuzione
            clock_t start = clock();
            bool result = gaussianElimination(n, k, matrix);
            clock_t end = clock();
            double tempo_esecuzione = ((double)(end - start)) / CLOCKS_PER_SEC;

            // Scrivi i risultati sul file CSV
            fprintf(csv_file, "%d,%d,%f,%f,%d\n", n, k, theta, tempo_esecuzione, result);

            // Libera la memoria
            for (int x = 0; x < n; x++) {
            free(matrix[x]);
            }
            free(matrix);

            // Stampa il risultato (opzionale)
            printf("n=%d, k=%d, theta=%f, Tempo: %f secondi, Risultato: %d\n", n, k, theta, tempo_esecuzione, result);
        }
    }

    // Chiudi il file CSV
    fclose(csv_file);

    return 0;
}

