#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include "seriale.h"


bool gaussianElimination(int n, int k, bool **matrix) {
    int rank = 0;
    bool solution[k-1];
    for (int i = 0; i < k; i++) {
            solution[i] = false;
    }


    for (int col = 0; col < k && rank < n; col++) {
        // Trova il pivot
        int pivot = -1;
        for (int row = rank; row < n; row++) {
            if (matrix[row][col]) {
                pivot = row;
                break;
            }
        }

        if (pivot == -1) continue; // Colonna nulla

        // Scambia la riga del pivot con la riga corrente
        if (pivot != rank) {
            for (int j = 0; j <= k; j++) {
                bool temp = matrix[rank][j];
                matrix[rank][j] = matrix[pivot][j];
                matrix[pivot][j] = temp;
            }

        }

        // Elimina la colonna sotto il pivot
        for (int row = rank + 1; row < n; row++) {
            if (matrix[row][col]) {
                for (int j = col; j <= k; j++) {
                    matrix[row][j] ^= matrix[rank][j]; //XOR tra pivot e colonna da eliminare, dato che le variabili sono booleane fare xor elemento per elemento corrisponde ad un'eliminazione
                }

            }
        }

        rank++;
        
    }


    // Controlla se il sistema è risolvibile
    for (int row = rank; row < n; row++) {
        if (matrix[row][k]) {
            printf("Sistema irrisolvibile.\n");
            return false;
        }
    }

    // Back substitution
    for (int i = rank - 1; i >= 0; i--) {
        solution[i] = matrix[i][k];
     
        for (int j = i + 1; j < k; j++) { // scorro tutte le variabili già risolte moltiplico (AND) il valore con il coefficiente 
            solution[i] ^= (matrix[i][j] && solution[j]); // é come spostare variabili a dx dell'equazione somma o sottrazione è sempre XOR
        }
    }

    //printSolution(solution, n, k);
    return true;
}

