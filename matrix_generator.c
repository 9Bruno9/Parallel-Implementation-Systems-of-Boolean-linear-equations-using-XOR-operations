#include <stdlib.h>
#include <time.h>
#include "matrix_generator.h"

void matrix_generator(int n, int k, double theta, bool **matrix) {
    // Inizializza il generatore di numeri casuali
    //srand(time(NULL));
    srand(42);
    // Riempie la matrice con 0 e 1 casuali
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < k; j++) {
            matrix[i][j] = (rand() / (double)RAND_MAX) < theta;
        }
    }

    // Assicura che nessuna colonna sia tutta zeros
    for (int j = 0; j < k; j++) {
        bool all_zeros = true;
        for (int i = 0; i < n; i++) {
            if (matrix[i][j]) {
                all_zeros = false;
                break;
            }
        }
        if (all_zeros) {
            int random_row = rand() % n;
            matrix[random_row][j] = true;
        }
    }
}
