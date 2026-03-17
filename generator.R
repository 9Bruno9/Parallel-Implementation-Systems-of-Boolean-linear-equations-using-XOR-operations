library(tidyverse)

setwd("C:/Users/Bruno/Desktop/Uni-parallele/Parallel-Implementation-Systems-of-Boolean-linear-equations-using-XOR-operations")

data_ser <- read.csv("./risultati_seriale.csv")

data_ser <-data_ser %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p1 <-read.csv("./risultati_p1.csv")

data_p1 <-data_p1 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))


plot(data_ser$n^2, data_ser$media, type="l")

data_p2 <-read.csv("./risultati_p2.csv")
data_p2 <-data_p2 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_ser <- data_ser %>% mutate(tipo = "seriale")
data_p1  <- data_p1 %>% mutate(tipo = "p1")
data_p2  <- data_p2 %>% mutate(tipo = "p2")

# Unisci i dataset
data_all <- bind_rows(data_ser, data_p1, data_p2)

ggplot(data_all, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo esecuzione",
    title = "Confronto tempi seriale vs p1"
  ) +
  theme_minimal(base_size = 14) # tema pulito


data_ser <- read.csv("./risultati_seriale.csv")

data_p1 <-read.csv("./risultati_p1.csv")
data_p2 <-read.csv("./risultati_p2.csv")


identical(data_p1$result, data_ser$result)
identical(data_p2$result, data_ser$result)
identical(data_p1$result, data_p2$result)

#####################################à


data_ser <- read.csv("result_data/risultati_seriale_01.csv")

data_ser <-data_ser %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p1 <-read.csv("result_data/risultati_p1_01.csv")

data_p1 <-data_p1 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))


plot(data_ser$n^2, data_ser$media, type="l")

data_p2 <-read.csv("result_data/risultati_p2_01.csv")
data_p2 <-data_p2 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_ser <- data_ser %>% mutate(tipo = "seriale")
data_p1  <- data_p1 %>% mutate(tipo = "p1")
data_p2  <- data_p2 %>% mutate(tipo = "p2")

# Unisci i dataset
data_all <- bind_rows(data_ser, data_p1, data_p2)

ggplot(data_all, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo esecuzione",
    title = "Confronto tempi seriale vs p1"
  ) +
  theme_minimal(base_size = 14) # tema pulito


data_ser <- read.csv("result_data/risultati_seriale_01.csv")

data_p1 <-read.csv("result_data/risultati_p1_01.csv")
data_p2 <-read.csv("result_data/risultati_p2_01.csv")


identical(data_p1$result, data_ser$result)
identical(data_p2$result, data_ser$result)
identical(data_p1$result, data_p2$result)






