library(tidyverse)
library(here)
setwd(here())


####COMPARISON SERIALE######################################
rm(list=ls())
data_s1 <- read.csv("result_data/risultati_seriale_01_20_3060.csv")
data_s2 <-  read.csv("result_data/risultati_seriale_03_20_3060.csv")
data_s3 <-  read.csv("result_data/risultati_seriale_05_20_3060.csv")
data_s4 <-  read.csv("result_data/risultati_seriale_07_20_3060.csv")
data_s5 <-  read.csv("result_data/risultati_seriale_09_20_3060.csv")


data_s1 <-data_s1 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta=as.factor(theta))

data_s2 <-data_s2 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))

data_s3 <-data_s3 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))

data_s4 <-data_s4 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))

data_s5 <-data_s5 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))


data_all <- bind_rows(data_s1, data_s2, data_s3, data_s4, data_s5)

ggplot(data_all, aes(x = n^2, y = t_medio, color = theta)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Theta",
    title = "Confronto tempi versione seriale al variare di theta"
  ) +
  theme_minimal(base_size = 14) # tema pulito

####COMPARISON P1###################################### 
rm(list=ls())
data_s1 <- read.csv("result_data/risultati_p1_01_20_3060.csv")
data_s2 <-  read.csv("result_data/risultati_p1_03_20_3060.csv")
data_s3 <-  read.csv("result_data/risultati_p1_05_20_3060.csv")
data_s4 <-  read.csv("result_data/risultati_p1_07_20_3060.csv")
data_s5 <-  read.csv("result_data/risultati_p1_09_20_3060.csv")



data_s1 <-data_s1 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta=as.factor(theta))

data_s2 <-data_s2 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))

data_s3 <-data_s3 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))

data_s4 <-data_s4 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))
data_s5 <-data_s5 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))


data_all <- bind_rows(data_s1, data_s2, data_s3, data_s4, data_s5)

ggplot(data_all, aes(x = n^2, y = t_medio, color = theta)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Theta",
    title = "Confronto tempi s_01 vs s_02"
  ) +
  theme_minimal(base_size = 14) # tema pulito


####COMPARISON P2###################################### 
rm(list=ls())
data_s1 <- read.csv("result_data/risultati_p2_01_20_3060.csv")
data_s2 <-  read.csv("result_data/risultati_p2_03_20_3060.csv")
data_s3 <-  read.csv("result_data/risultati_p2_05_20_3060.csv")
data_s4 <-  read.csv("result_data/risultati_p2_07_20_3060.csv")
data_s5 <-  read.csv("result_data/risultati_p2_09_20_3060.csv")

data_s1 <-data_s1 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta=as.factor(theta))

data_s2 <-data_s2 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))

data_s3 <-data_s3 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))

data_s4 <-data_s4 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))

data_s5 <-data_s5 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))


data_all <- bind_rows(data_s1, data_s2, data_s3, data_s4, data_s5)

ggplot(data_all, aes(x = n^2, y = t_medio, color = theta)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Theta",
    title = "Confronto tempi s_01 vs s_02"
  ) +
  theme_minimal(base_size = 14) # tema pulito


####COMPARISON P3###################################### 
rm(list=ls())
data_s1 <- read.csv("result_data/risultati_p3_01_20_3060.csv")
data_s2 <-  read.csv("result_data/risultati_p3_03_20_3060.csv")
data_s3 <-  read.csv("result_data/risultati_p3_05_20_3060.csv")
data_s4 <-  read.csv("result_data/risultati_p3_07_20_3060.csv")
data_s5 <-  read.csv("result_data/risultati_p3_09_20_3060.csv")

data_s1 <-data_s1 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta=as.factor(theta))

data_s2 <-data_s2 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))

data_s3 <-data_s3 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))

data_s4 <-data_s4 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))

data_s5 <-data_s5 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))


data_all <- bind_rows(data_s1, data_s2, data_s3, data_s4, data_s5)

ggplot(data_all, aes(x = n^2, y = t_medio, color = theta)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Theta",
    title = "Confronto tempi s_01 vs s_02"
  ) +
  theme_minimal(base_size = 14) # tema pulito


####COMPARISON P4###################################### 
rm(list=ls())
data_s1 <- read.csv("result_data/risultati_p4_01_20_3060.csv")
data_s2 <-  read.csv("result_data/risultati_p4_03_20_3060.csv")
data_s3 <-  read.csv("result_data/risultati_p4_05_20_3060.csv")
data_s4 <-  read.csv("result_data/risultati_p4_07_20_3060.csv")
data_s5 <-  read.csv("result_data/risultati_p4_09_20_3060.csv")

data_s1 <-data_s1 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta=as.factor(theta))

data_s2 <-data_s2 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))

data_s3 <-data_s3 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))

data_s4 <-data_s4 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))
data_s5 <-data_s5 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))


data_all <- bind_rows(data_s1, data_s2, data_s3, data_s4, data_s5)

ggplot(data_all, aes(x = n^2, y = t_medio, color = theta)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Theta",
    title = "Confronto tempi s_01 vs s_02"
  ) +
  theme_minimal(base_size = 14) # tema pulito

####COMPARISON P5###################################### 
rm(list=ls())
data_s1 <- read.csv("result_data/risultati_p5_01_20_3060.csv")
data_s2 <-  read.csv("result_data/risultati_p5_03_20_3060.csv")
data_s3 <-  read.csv("result_data/risultati_p5_05_20_3060.csv")
data_s4 <-  read.csv("result_data/risultati_p5_07_20_3060.csv")
data_s5 <-  read.csv("result_data/risultati_p5_09_20_3060.csv")

data_s1 <-data_s1 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta=as.factor(theta))

data_s2 <-data_s2 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))

data_s3 <-data_s3 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))

data_s4 <-data_s4 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))
data_s5 <-data_s5 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione), theta = as.factor(theta))


data_all <- bind_rows(data_s1, data_s2, data_s3, data_s4, data_s5)

ggplot(data_all, aes(x = n^2, y = t_medio, color = theta)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Theta",
    title = "Confronto tempi s_01 vs s_02"
  ) +
  theme_minimal(base_size = 14) # tema pulito


# ALL COMPARISON ###################


# Funzione per leggere e processare i dataset di un certo tipo (es. p1, p2, ecc.)
rm(list=ls())

process_type <- function(type, thetas) {
  all_data <- list()
  for (theta in thetas) {
    # Costruisci il percorso del file
    file_path <- paste0("result_data/risultati_", type, "_", theta, "_20_3060.csv")
    # Verifica se il file esiste
    if (file.exists(file_path)) {
      data <- read.csv(file_path)
      data <- data %>%
        group_by(n) %>%
        summarise(t_medio = mean(tempo_esecuzione)) %>%
        mutate(theta = theta)
      all_data[[theta]] <- data
    } else {
      message("File non trovato: ", file_path)
    }
  }
  # Combina i dati per il tipo corrente
  combined <- bind_rows(all_data)
  # Calcola la media per ogni n e theta
  combined <- combined %>%
    group_by(n) %>%
    summarise(t_medio = mean(t_medio)) %>%
    mutate(tipo = type)
  return(combined)
}

# Elenco dei tipi e dei valori di theta
types <- c("seriale", "p1", "p2", "p3", "p4", "p5")
# types <- c("p3", "p4", "p5")
thetas <- c("01", "03", "05","07", "09")

# Processa tutti i tipi e combina i risultati
all_data <- map_dfr(types, ~ process_type(.x, thetas))

# Plot finale: confronto per tipo e theta
ggplot(all_data, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo esecuzione",
    linetype = "Theta",
    title = "Confronto tempi medi per tipo"
  ) +
  theme_minimal(base_size = 14)

p3_p4_data <- all_data %>%
  filter(tipo %in% c("p3", "p4", "p5"))

ggplot(p3_p4_data, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo esecuzione",
    linetype = "Theta",
    title = "Confronto tempi medi per p3 e p4"
  ) +
  theme_minimal(base_size = 14)

###SINTESI ###############
library(tidyverse)
library(here)

setwd(here())
rm(list=ls())
process_file <- function(file_path) {
  read.csv(file_path) %>%
    group_by(n) %>%
    summarise(t_medio = mean(tempo_esecuzione), .groups = "drop")
}

types  <- c( "p3", "p4", "p5")#c("seriale","p1", "p2", "p3", "p4", "p5")
thetas <- c("05", "07", "09")

data_all <- expand_grid(tipo = types, theta = thetas) %>%
  mutate(file = paste0("result_data/risultati_", tipo, "_", theta, "_30_3060.csv")) %>%
  filter(file.exists(file)) %>%
  pmap_dfr(function(tipo, theta, file) {
    process_file(file) %>%
      mutate(tipo = tipo, theta = theta)
  })

# 🔥 MEDIA SU TUTTI I THETA
data_mean <- data_all %>%
  group_by(tipo, n) %>%
  summarise(t_medio = mean(t_medio), .groups = "drop")

# 📊 UNICO PLOT
ggplot(data_mean, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo",
    title = "Tempo di esecuzione medio per ogni versione (media su tutti i theta) \n| Intel Core i7 5820K | NVIDIA GeForce RTX 3060"
  ) +
  theme_minimal(base_size = 14)

#Più plot
ggplot(data_all, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +
  facet_wrap(~ theta, labeller = labeller(theta = function(x) paste("theta =", x))) +
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo",
    title = "Tempo medio di esecuzione per ogni versione e per ogni theta \n| Intel Core i7 5820K | NVIDIA GeForce RTX 3060"
  ) +
  theme_minimal(base_size = 14)


###########CORRETTEZZA#################


check_results <- function(theta) {
  base <- read.csv(paste0("result_data/risultati_seriale_", theta, "_20_3060.csv"))
  
  map(types[-1], function(t) {
    df <- read.csv(paste0("result_data/risultati_", t, "_", theta, "_20_3060.csv"))
    identical(df$result, base$result)
  })
}

check_results("09")

check_results3_5 <- function(theta) {
  base <- read.csv(paste0("result_data/risultati_p3_",theta,"_30_3060.csv"))
  
  map(types[-1], function(t) {
    df <- read.csv(paste0("result_data/risultati_", t, "_", theta, "_30_3060.csv"))
    identical(df$result, base$result)
  })
}

check_results3_5("05")


