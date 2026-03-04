#ifndef MATRIX_GENERATOR_H
#define MATRIX_GENERATOR_H

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

void matrix_generator(int n, int k, double theta, bool **matrix);

#ifdef __cplusplus
}
#endif

#endif