#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
 
#define MAX_VAR 100

bool stamp = true;

void printSolution(bool *solution, int n, int k) {
    printf("Soluzione trovata:\n");
    for (int i = 0; i < k; i++) {
        printf("x%d = %d\n", i + 1, solution[i]);
    }
}
/*
void printMatrix( int n, int k, bool matrice[n][k]){
    
    for(int i = 0 ; i<n; i++){
        for(int j =0; j<3; j++){
            printf("%d ", matrice[i][j]);
            if(j==k-1) printf("| ");
        }
        printf("\n");
    }
    printf("\n");
}

*/

void printMatrix(int n, int k, bool matrice[n][k]) {
    for(int i = 0; i < n; i++) {
        for(int j = 0; j < k; j++) { // Stampa tutti i k valori per riga
            printf("%d ", matrice[i][j]);
            if(j == k-1) printf("| ");
        }
        printf("\n");
    }
    printf("\n");
}


bool gaussianElimination(int n, int k, bool matrix[n][k]) {
    int rank = 0;
    bool solution[MAX_VAR] = {false};

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
            if(stamp){
                printf("Scambio la riga %d con la riga %d \n", rank, pivot);
                printMatrix( n, k, matrix);
            }
        }

        // Elimina la colonna sotto il pivot
        for (int row = rank + 1; row < n; row++) {
            if (matrix[row][col]) {
                for (int j = col; j <= k; j++) {
                    matrix[row][j] ^= matrix[rank][j]; //XOR tra pivot e colonna da eliminare, dato che le variabili sono booleane fare xor elemento per elemento corrisponde ad un'eliminazione
                }
                if(stamp){
                    printf("sottraggo alla riga %d la riga %d \n", row, rank);
                    printMatrix( n, k, matrix);
                }
            }
        }

        rank++;
        
    }
    //printf("rank è pari a %d", rank);

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

    printSolution(solution, n, k);
    return true;
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
    char line[MAX_VAR * 2 + 2]; // Buffer per leggere ogni riga
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

    bool matrice[n][k];
     
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

    if (!gaussianElimination(n, k, matrice)) {
        return 1;
    }

    return 0;
}
