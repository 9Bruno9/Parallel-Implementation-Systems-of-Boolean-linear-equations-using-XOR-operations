#ifndef SERIALE_H
#define SERIALE_H

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

bool gaussianElimination(int n, int k, bool **matrix, bool *solution);

#ifdef __cplusplus
}
#endif

#endif