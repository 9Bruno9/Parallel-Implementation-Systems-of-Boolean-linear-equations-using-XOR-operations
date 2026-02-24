setwd("C:/Users/Bruno/Desktop/Uni-parallele/Parallel-Implementation-Systems-of-Boolean-linear-equations-using-XOR-operations/test")
n = 5;
k = 9;

theta = 0.5;

matrice = matrix(rbinom(n*k, 1, theta), nrow=n, ncol=k)
matrice


for (x in 1:k) {
  if (sum(matrice[,x]) == 0){
    matrice[round(runif(1,1,n)),x]=1
  }
}



# Salva la matrice in un file di testo
write.table(matrice, file = "test2.txt", row.names = FALSE, col.names = FALSE, sep = " ")
