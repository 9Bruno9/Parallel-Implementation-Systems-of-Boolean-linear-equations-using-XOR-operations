# Parallel-Implementation-Systems-of-Boolean-linear-equations-using-XOR-operations


Progetto sviluppato per il corso di Programmazione su Architetture Parallele  
Corso di Laurea Magistrale in Informatica – Università degli Studi di Udine

## 📌 Descrizione

Questo progetto ha l’obiettivo di risolvere sistemi di equazioni lineari booleani, in cui coefficienti e variabili appartengono al campo finito F₂ e l’operazione principale è l’operatore XOR.

L’approccio adottato si basa su una variante dell’algoritmo di Gauss-Jordan adattata al caso booleano. Il progetto esplora diverse strategie di parallelizzazione su GPU utilizzando CUDA, con l’obiettivo di migliorare le prestazioni rispetto alla versione seriale.

## ⚙️ Caratteristiche principali

- Risoluzione di sistemi lineari booleani (modulo 2)
- Implementazione dell’eliminazione di Gauss-Jordan con XOR
- Versione seriale in C
- 5 versioni parallele in CUDA con ottimizzazioni progressive
- Analisi sperimentale delle prestazioni

## 🧠 Versioni implementate

- **Seriale**: implementazione base utilizzata come benchmark
- **p1**: parallelizzazione della sola fase di eliminazione
- **p2**: introduzione del bit-packing per migliorare l’efficienza
- **p3**: parallelizzazione completa con riduzione dei trasferimenti CPU-GPU
- **p4**: utilizzo del dynamic parallelism (CUDA)
- **p5**: ottimizzazione con uso della shared memory

## 🛠️ Requisiti

- GCC
- NVIDIA CUDA Toolkit (>= 12)
- GPU NVIDIA compatibile (architettura sm_86 o simile)
- Make

## 🔧 Compilazione

Per compilare l’intero progetto:

```bash
make main