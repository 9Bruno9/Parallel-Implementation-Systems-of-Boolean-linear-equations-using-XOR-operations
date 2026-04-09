library(tidyverse)
library(here)

library(dplyr)
library(tidyr)
library(knitr)
library(kableExtra)
setwd(here())


###VISUALIZZAZIONI E TABELLE ###############
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
thetas <- c("01","03","05", "07", "09")

data_all <- expand_grid(tipo = types, theta = thetas) %>%
  mutate(file = paste0("result_data/risultati_", tipo, "_", theta, "_40_3060.csv")) %>%
  filter(file.exists(file)) %>%
  pmap_dfr(function(tipo, theta, file) {
    process_file(file) %>%
      mutate(tipo = tipo, theta = theta)
  })

###TABELLA RISULTATI
create_latex_table <- function(data, caption = "Tempi medi", label = "tab:tempi") {

  
  table <- data %>%
    group_by(tipo, n) %>%
    summarise(t_medio = mean(t_medio), .groups = "drop") %>%
    pivot_wider(names_from = tipo, values_from = t_medio) %>%
    arrange(n)
  
  # 🔥 FORMATTAZIONE + BOLD DEL MINIMO PER RIGA
  table_fmt <- table %>%
    rowwise() %>%
    mutate(
      min_val = min(c_across(-n), na.rm = TRUE),
      across(
        -c(n, min_val),
        ~ ifelse(. == min_val,
                 paste0("\\textbf{", sprintf("%.4f", .), "}"),
                 sprintf("%.4f", .))
      )
    ) %>%
    ungroup() %>%
    select(-min_val)
  
  table_fmt %>%
    kable(
      format = "latex",
      booktabs = TRUE,
      escape = FALSE,  # 🔥 IMPORTANTISSIMO per il bold
      caption = caption,
      label = label
    ) %>%
    kable_styling(latex_options = c("hold_position"))
}
latex_tabella <- create_latex_table(
  data_all,
  caption = "Tempo medio di esecuzione per ogni versione (media su tutti i theta)",
  label = "tab:tempi_versioni"
)

cat(latex_tabella)


tabella_tempi <- create_time_table(data_all)

print(tabella_tempi)

data_mean <- data_all %>%
  group_by(tipo, n) %>%
  summarise(t_medio = mean(t_medio), .groups = "drop")

# UNICO PLOT
ggplot(data_mean, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo",
    title = "Tempo di esecuzione medio per ogni versione (media su tutti i theta) \n| Intel Core i7 5820K | NVIDIA GeForce RTX 3060"
  ) +
  theme_minimal(base_size = 14)

#Più plot per diversi theta
ggplot(data_all, aes(x = n^2, y = t_medio, color = tipo)) +
  geom_line(size = 1) +
  facet_wrap(~ theta, labeller = labeller(theta = function(x) paste("theta =", x))) +
  labs(
    x = "n^2",
    y = "Tempo medio di esecuzione",
    color = "Tipo",
    title = "Tempo medio di esecuzione per ogni versione e per ogni theta \n| Intel Core i7 5820K | NVIDIA GeForce RTX 3060"#AMD Ryzen 7 5800H | NVIDIA GeForce RTX 3050 Ti Laptop GPU"
  ) +
  theme_minimal(base_size = 14)


###########CONTROLLO CORRETTEZZA SOLUZIONI#################


check_results <- function(theta) {
  base <- read.csv(paste0("result_data/risultati_seriale_", theta, "_40_3060.csv"))
  
  map(types[-1], function(t) {
    df <- read.csv(paste0("result_data/risultati_", t, "_", theta, "_40_3060.csv"))
    identical(df$result, base$result)
  })
}

check_results("09")

check_results3_5 <- function(theta) {
  base <- read.csv(paste0("result_data/risultati_p3_",theta,"_40_3060.csv"))
  
  map(types[-1], function(t) {
    df <- read.csv(paste0("result_data/risultati_", t, "_", theta, "_40_3060.csv"))
    identical(df$result, base$result)
  })
}

check_results3_5("09")


