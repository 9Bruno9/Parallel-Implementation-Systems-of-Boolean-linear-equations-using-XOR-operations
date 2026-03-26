library(tidyverse)
library(here)
setwd(here())


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

####01#######################################


data_ser <- read.csv("result_data/risultati_seriale_01_10.csv")

data_ser <-data_ser %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p1 <-read.csv("result_data/risultati_p1_01_10.csv")

data_p1 <-data_p1 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))



data_p2 <-read.csv("result_data/risultati_p2_01_10.csv")
data_p2 <-data_p2 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p3 <-read.csv("result_data/risultati_p3_01_10.csv")
data_p3 <-data_p3 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p4 <-read.csv("result_data/risultati_p4_05_10.csv")
data_p4 <-data_p4 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_ser <- data_ser %>% mutate(tipo = "seriale")
data_p1  <- data_p1 %>% mutate(tipo = "p1")
data_p2  <- data_p2 %>% mutate(tipo = "p2")
data_p3  <- data_p3 %>% mutate(tipo = "p3")
data_p4  <- data_p4 %>% mutate(tipo = "p4")
# Unisci i dataset
data_all <- bind_rows(data_ser, data_p1, data_p2, data_p3, data_p4)
#data_all <- bind_rows(data_p2, data_p3)



ggplot(data_all, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo esecuzione",
    title = "Confronto tempi seriale vs p1 vs p2 vs p3; theta = 0.1"
  ) +
  theme_minimal(base_size = 14) # tema pulito


data_ser <- read.csv("result_data/risultati_seriale_01_10.csv")

data_p1 <-read.csv("result_data/risultati_p1_01_10.csv")
data_p2 <-read.csv("result_data/risultati_p2_01_10.csv")
data_p3 <-read.csv("result_data/risultati_p3_01_10.csv")
data_p4 <-read.csv("result_data/risultati_p4_01_10.csv")

identical(data_p1$result, data_ser$result)
identical(data_p2$result, data_ser$result)
identical(data_p1$result, data_p2$result)
identical(data_p3$result, data_ser$result)
identical(data_p4$result, data_ser$result)


####03#######################################


data_ser <- read.csv("result_data/risultati_seriale_03.csv")

data_ser <-data_ser %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p1 <-read.csv("result_data/risultati_p1_03.csv")

data_p1 <-data_p1 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))


plot(data_ser$n^2, data_ser$media, type="l")

data_p2 <-read.csv("result_data/risultati_p2_03.csv")
data_p2 <-data_p2 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p3 <-read.csv("result_data/risultati_p3_03.csv")
data_p3 <-data_p3 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_ser <- data_ser %>% mutate(tipo = "seriale")
data_p1  <- data_p1 %>% mutate(tipo = "p1")
data_p2  <- data_p2 %>% mutate(tipo = "p2")
data_p3  <- data_p3 %>% mutate(tipo = "p3")
# Unisci i dataset
#data_all <- bind_rows(data_ser, data_p1, data_p2, data_p3)
data_all <- bind_rows(data_p2, data_p3)



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


data_ser <- read.csv("result_data/risultati_seriale_03.csv")

data_p1 <-read.csv("result_data/risultati_p1_03.csv")
data_p2 <-read.csv("result_data/risultati_p2_03.csv")
data_p3 <-read.csv("result_data/risultati_p3_03.csv")

identical(data_p1$result, data_ser$result)
identical(data_p2$result, data_ser$result)
identical(data_p1$result, data_ser$result)
identical(data_p4$result, data_ser$result)


### 05 ################

data_ser <- read.csv("result_data/risultati_seriale_05_15_3050.csv")

data_ser <-data_ser %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p1 <-read.csv("result_data/risultati_p1_05_15_3050.csv")

data_p1 <-data_p1 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))


data_p2 <-read.csv("result_data/risultati_p2_05_15_3050.csv")
data_p2 <-data_p2 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p3 <-read.csv("result_data/risultati_p3_05_15_3050.csv")
data_p3 <-data_p3 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p4 <-read.csv("result_data/risultati_p4_05_15_3050.csv")
data_p4 <-data_p4 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_p5 <-read.csv("result_data/risultati_p5_05_15_3050.csv")
data_p5 <-data_p5 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_ser <- data_ser %>% mutate(tipo = "seriale")
data_p1  <- data_p1 %>% mutate(tipo = "p1")
data_p2  <- data_p2 %>% mutate(tipo = "p2")
data_p3  <- data_p3 %>% mutate(tipo = "p3")
data_p4  <- data_p4 %>% mutate(tipo = "p4")
data_p5  <- data_p4 %>% mutate(tipo = "p5")
# Unisci i dataset
data_all <- bind_rows(data_ser, data_p1, data_p2, data_p3)
data_all <- bind_rows(data_p3)



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


data_ser <- read.csv("result_data/risultati_seriale_05_15_3050.csv")

data_p1 <-read.csv("result_data/risultati_p1_05_15_3050.csv")
data_p2 <-read.csv("result_data/risultati_p2_05_15_3050.csv")
data_p3 <-read.csv("result_data/risultati_p3_05_15_3050.csv")
data_p4 <-read.csv("result_data/risultati_p4_05_15_3050.csv")
data_p5 <-read.csv("result_data/risultati_p5_05_15_3050.csv")

identical(data_p1$result, data_ser$result)
identical(data_p2$result, data_ser$result)
identical(data_p3$result, data_ser$result)
identical(data_p4$result, data_ser$result)
identical(data_p5$result, data_ser$result)

identical(data_p5$result, data_p2$result)


####COMPARISON P1######################################

data_p1 <- read.csv("result_data/risultati_seriale_01.csv")
data_p2 <-  read.csv("result_data/risultati_seriale_02.csv")


data_s1 <-data_s1 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_s2 <-data_s2 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_s1 <- data_s1 %>% mutate(tipo = "s1")
data_s2  <- data_s2 %>% mutate(tipo = "s2")

data_all <- bind_rows(data_s1, data_s2)

ggplot(data_all, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo esecuzione",
    title = "Confronto tempi s_01 vs s_02"
  ) +
  theme_minimal(base_size = 14) # tema pulito


data_s1 <- read.csv("result_data/risultati_seriale_01.csv")
data_s2 <-  read.csv("result_data/risultati_seriale_02.csv")


data_s1 <-data_s1 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_s2 <-data_s2 %>%
  group_by(n) %>%
  summarise(t_medio = mean(tempo_esecuzione))

data_s1 <- data_s1 %>% mutate(tipo = "s1")
data_s2  <- data_s2 %>% mutate(tipo = "s2")

data_all <- bind_rows(data_s1, data_s2)

ggplot(data_all, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +       
  #geom_point() +                
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo esecuzione",
    title = "Confronto tempi s_01 vs s_02"
  ) +
  theme_minimal(base_size = 14) # tema pulito
