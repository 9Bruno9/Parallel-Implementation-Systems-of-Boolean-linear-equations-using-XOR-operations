#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include "seriale.h"




bool stamp = true;

void printSolution(bool *solution, int n, int k) {
    printf("Soluzione trovata:\n");
    for (int i = 0; i < k-1; i++) {
        printf("x%d = %d\n", i + 1, solution[i]);
    }
}


void printMatrix(int n, int k, bool **matrice){
    for(int i = 0; i < n; i++) {
        for(int j = 0; j < k; j++) { // Stampa tutti i k valori per riga
            printf("%d ", matrice[i][j]);
            if(j == k-2) printf("| ");
        }
        printf("\n");
    }
    printf("\n");
}



int main(int argc, char *argv[]) {


    if (argc < 2) {
        printf("Uso: %s <nome_file> \n", argv[0]);
        return 1;
    }

    FILE *file = fopen(argv[1], "r");
    if (!file) {
        printf("Errore nell'apertura del file.\n");
        return 1;
    }



    // Leggi il file per determinare n e k
    char line[100 * 2 + 2]; // Buffer per leggere ogni riga
    int n = 0;
    int k = 0;

    // Prima passata: conta il numero di righe (n) e il numero di colonne (k)
    while (fgets(line, sizeof(line), file) != NULL) {
        int count = 0;
        char *token = strtok(line, " \t\n");
        while (token != NULL) {
            count++;
            token = strtok(NULL, " \t\n");
        }
        if (count > 0) {
            if (k == 0) {
                k = count ; // L'ultima colonna è il termine noto
            }
            n++;
        }
    }

    // Resetta il puntatore del file all'inizio
    rewind(file);

    bool **matrice = (bool **)malloc(n * sizeof(bool *));
    for (int x = 0; x < n; x++) {
        matrice[x] = (bool *)malloc(k * sizeof(bool));
    }
    // Leggi la matrice
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < k; j++) {
            int val;
            fscanf(file, "%d", &val);
            matrice[i][j] = (bool)val;
        }
    }

    fclose(file);

    printMatrix(n, k, matrice);

    bool *solution = malloc((k-1) * sizeof(bool));

    if (!gaussianElimination(n, k, matrice, solution)) {
        printf("sistema irrisolvibile \n");
        return 0;
    }

    printSolution(solution, n, k);

    return 0;
}
