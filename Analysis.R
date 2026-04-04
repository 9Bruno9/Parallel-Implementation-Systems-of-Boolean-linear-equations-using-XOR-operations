library(tidyverse)
library(here)
setwd(here())


####01#######################################
data_ser <- read.csv("result_data/risultati_seriale_01_20_3060.csv")

data_ser <-data_ser %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p1 <-read.csv("result_data/risultati_p1_01_20_3060.csv")

data_p1 <-data_p1 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))


data_p2 <-read.csv("result_data/risultati_p2_01_20_3060.csv")
data_p2 <-data_p2 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p3 <-read.csv("result_data/risultati_p3_01_20_3060.csv")
data_p3 <-data_p3 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p4 <-read.csv("result_data/risultati_p4_01_20_3060.csv")
data_p4 <-data_p4 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p5 <-read.csv("result_data/risultati_p5_01_20_3050.csv")
data_p5 <-data_p5 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_ser <- data_ser %>% mutate(tipo = "seriale")
data_p1  <- data_p1 %>% mutate(tipo = "p1")
data_p2  <- data_p2 %>% mutate(tipo = "p2")
data_p3  <- data_p3 %>% mutate(tipo = "p3")
data_p4  <- data_p4 %>% mutate(tipo = "p4")
data_p5  <- data_p5 %>% mutate(tipo = "p5")
# Unisci i dataset
data_all <- bind_rows(data_ser, data_p1, data_p2, data_p3 , data_p4)




ggplot(data_all, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo esecuzione",
    title = "Confronto tempi seriale vs p1 vs p2 vs p3 vs p4;\n theta =0.1"
  ) +
  theme_minimal(base_size = 14) # tema pulito


#secondo plot
data_all <- bind_rows(data_p3, data_p4)
ggplot(data_all, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo esecuzione",
    title = "Confronto tempi p3 vs p4; theta =0.1"
  ) +
  theme_minimal(base_size = 14) # tema pulito





data_ser <- read.csv("result_data/risultati_seriale_01_20_3060.csv")

data_p1 <-read.csv("result_data/risultati_p1_01_20_3060.csv")
data_p2 <-read.csv("result_data/risultati_p2_01_20_3060.csv")
data_p3 <-read.csv("result_data/risultati_p3_01_20_3060.csv")
data_p4 <-read.csv("result_data/risultati_p4_01_20_3060.csv")
data_p5 <-read.csv("result_data/risultati_p5_01_20_3050.csv")

identical(data_p1$result, data_ser$result)
identical(data_p2$result, data_ser$result)
identical(data_p3$result, data_ser$result)
identical(data_p4$result, data_ser$result)
identical(data_p5$result, data_ser$result)

identical(data_p5$result, data_p3$result)



####03#######################################


data_ser <- read.csv("result_data/risultati_seriale_03_20_3060.csv")
data_p1 <-read.csv("result_data/risultati_p1_03_20_3060.csv")
data_p2 <-read.csv("result_data/risultati_p2_03_20_3060.csv")
data_p3 <-read.csv("result_data/risultati_p3_03_20_3060.csv")
data_p4 <-read.csv("result_data/risultati_p4_03_20_3060.csv")

identical(data_p1$result, data_ser$result)
identical(data_p2$result, data_ser$result)
identical(data_p3$result, data_ser$result)
identical(data_p4$result, data_ser$result)
identical(data_p5$result, data_ser$result)



data_ser <- read.csv("result_data/risultati_seriale_03_20_3060.csv")

data_ser <-data_ser %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p1 <-read.csv("result_data/risultati_p1_03_20_3060.csv")

data_p1 <-data_p1 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))


data_p2 <-read.csv("result_data/risultati_p2_03_20_3060.csv")
data_p2 <-data_p2 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p3 <-read.csv("result_data/risultati_p3_03_20_3060.csv")
data_p3 <-data_p3 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p4 <-read.csv("result_data/risultati_p4_03_20_3060.csv")
data_p4 <-data_p4 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_ser <- data_ser %>% mutate(tipo = "seriale")
data_p1  <- data_p1 %>% mutate(tipo = "p1")
data_p2  <- data_p2 %>% mutate(tipo = "p2")
data_p3  <- data_p3 %>% mutate(tipo = "p3")
data_p4  <- data_p4 %>% mutate(tipo = "p4")
# Unisci i dataset
data_all <- bind_rows(data_ser, data_p1, data_p2, data_p3 , data_p4)

ggplot(data_all, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo esecuzione",
    title = "Confronto tempi seriale vs p1 vs p2 vs p3 vs p4;\n theta =0.5"
  ) +
  theme_minimal(base_size = 14) # tema pulito


#secondo plot
data_all <- bind_rows(data_p3, data_p4)
ggplot(data_all, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo esecuzione",
    title = "Confronto tempi p3 vs p4; theta =0.5"
  ) +
  theme_minimal(base_size = 14) # tema pulito






### 05 ################

data_ser <- read.csv("result_data/risultati_seriale_05_20_3060.csv")

data_p1 <-read.csv("result_data/risultati_p1_05_20_3060.csv")
data_p2 <-read.csv("result_data/risultati_p2_05_20_3060.csv")
data_p3 <-read.csv("result_data/risultati_p3_05_20_3060.csv")
data_p4 <-read.csv("result_data/risultati_p4_05_20_3060.csv")

identical(data_p1$result, data_ser$result)
identical(data_p2$result, data_ser$result)
identical(data_p3$result, data_ser$result)
identical(data_p4$result, data_ser$result)



data_ser <- read.csv("result_data/risultati_seriale_05_20_3060.csv")

data_ser <-data_ser %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p1 <-read.csv("result_data/risultati_p1_05_20_3060.csv")

data_p1 <-data_p1 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))


data_p2 <-read.csv("result_data/risultati_p2_05_20_3060.csv")
data_p2 <-data_p2 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p3 <-read.csv("result_data/risultati_p3_05_20_3060.csv")
data_p3 <-data_p3 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p4 <-read.csv("result_data/risultati_p4_05_20_3060.csv")
data_p4 <-data_p4 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p5 <-read.csv("result_data/risultati_p5_05_20_3060.csv")
data_p5 <-data_p5 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_ser <- data_ser %>% mutate(tipo = "seriale")
data_p1  <- data_p1 %>% mutate(tipo = "p1")
data_p2  <- data_p2 %>% mutate(tipo = "p2")
data_p3  <- data_p3 %>% mutate(tipo = "p3")
data_p4  <- data_p4 %>% mutate(tipo = "p4")
# Unisci i dataset
data_all <- bind_rows(data_ser, data_p1, data_p2, data_p3 , data_p4)

ggplot(data_all, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo esecuzione",
    title = "Confronto tempi seriale vs p1 vs p2 vs p3 vs p4;\n theta =0.5"
  ) +
  theme_minimal(base_size = 14) # tema pulito


#secondo plot
data_all <- bind_rows(data_p3, data_p4)
ggplot(data_all, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo esecuzione",
    title = "Confronto tempi p3 vs p4; theta =0.5"
  ) +
  theme_minimal(base_size = 14) # tema pulito




### 07 ################

data_ser <- read.csv("result_data/risultati_seriale_07_20_3060.csv")

data_p1 <-read.csv("result_data/risultati_p1_07_20_3060.csv")
data_p2 <-read.csv("result_data/risultati_p2_07_20_3060.csv")
data_p3 <-read.csv("result_data/risultati_p3_07_20_3060.csv")
data_p4 <-read.csv("result_data/risultati_p4_07_20_3060.csv")

identical(data_p1$result, data_ser$result)
identical(data_p2$result, data_ser$result)
identical(data_p3$result, data_ser$result)
identical(data_p4$result, data_ser$result)



data_ser <- read.csv("result_data/risultati_seriale_07_20_3060.csv")

data_ser <-data_ser %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p1 <-read.csv("result_data/risultati_p1_07_20_3060.csv")

data_p1 <-data_p1 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))


data_p2 <-read.csv("result_data/risultati_p2_07_20_3060.csv")
data_p2 <-data_p2 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p3 <-read.csv("result_data/risultati_p3_07_20_3060.csv")
data_p3 <-data_p3 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p4 <-read.csv("result_data/risultati_p4_07_20_3060.csv")
data_p4 <-data_p4 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p5 <-read.csv("result_data/risultati_p5_07_20_3060.csv")
data_p5 <-data_p5 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_ser <- data_ser %>% mutate(tipo = "seriale")
data_p1  <- data_p1 %>% mutate(tipo = "p1")
data_p2  <- data_p2 %>% mutate(tipo = "p2")
data_p3  <- data_p3 %>% mutate(tipo = "p3")
data_p4  <- data_p4 %>% mutate(tipo = "p4")
# Unisci i dataset
data_all <- bind_rows(data_ser, data_p1, data_p2, data_p3 , data_p4)

ggplot(data_all, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo esecuzione",
    title = "Confronto tempi seriale vs p1 vs p2 vs p3 vs p4;\n theta =0.5"
  ) +
  theme_minimal(base_size = 14) # tema pulito


#secondo plot
data_all <- bind_rows(data_p3, data_p4)
ggplot(data_all, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo esecuzione",
    title = "Confronto tempi p3 vs p4; theta =0.5"
  ) +
  theme_minimal(base_size = 14) # tema pulito



### 09 ################

data_ser <- read.csv("result_data/risultati_seriale_09_20_3060.csv")

data_p1 <-read.csv("result_data/risultati_p1_09_20_3060.csv")
data_p2 <-read.csv("result_data/risultati_p2_09_20_3060.csv")
data_p3 <-read.csv("result_data/risultati_p3_09_20_3060.csv")
data_p4 <-read.csv("result_data/risultati_p4_09_20_3060.csv")

identical(data_p1$result, data_ser$result)
identical(data_p2$result, data_ser$result)
identical(data_p3$result, data_ser$result)
identical(data_p4$result, data_ser$result)



data_ser <- read.csv("result_data/risultati_seriale_09_20_3060.csv")

data_ser <-data_ser %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p1 <-read.csv("result_data/risultati_p1_09_20_3060.csv")

data_p1 <-data_p1 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))


data_p2 <-read.csv("result_data/risultati_p2_09_20_3060.csv")
data_p2 <-data_p2 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p3 <-read.csv("result_data/risultati_p3_09_20_3060.csv")
data_p3 <-data_p3 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p4 <-read.csv("result_data/risultati_p4_09_20_3060.csv")
data_p4 <-data_p4 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))


data_ser <- data_ser %>% mutate(tipo = "seriale")
data_p1  <- data_p1 %>% mutate(tipo = "p1")
data_p2  <- data_p2 %>% mutate(tipo = "p2")
data_p3  <- data_p3 %>% mutate(tipo = "p3")
data_p4  <- data_p4 %>% mutate(tipo = "p4")
# Unisci i dataset
data_all <- bind_rows(data_ser, data_p1, data_p2, data_p3 , data_p4)

ggplot(data_all, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo esecuzione",
    title = "Confronto tempi seriale vs p1 vs p2 vs p3 vs p4;\n theta =0.5"
  ) +
  theme_minimal(base_size = 14) # tema pulito


#secondo plot
data_all <- bind_rows(data_p3, data_p4)
ggplot(data_all, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo esecuzione",
    title = "Confronto tempi p3 vs p4; theta =0.5"
  ) +
  theme_minimal(base_size = 14) # tema pulito


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


data_all <- bind_rows(data_s1, data_s2, data_s3, data_s4)

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


data_all <- bind_rows(data_s1, data_s2, data_s3, data_s4)

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


data_all <- bind_rows(data_s1, data_s2, data_s3, data_s4)

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


data_all <- bind_rows(data_s1, data_s2, data_s3, data_s4)

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


data_all <- bind_rows(data_s1, data_s2, data_s3, data_s4)

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
types <- c("seriale", "p1", "p2", "p3", "p4")
thetas <- c("01", "03", "05","07")

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
  filter(tipo %in% c("p3", "p4"))

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
