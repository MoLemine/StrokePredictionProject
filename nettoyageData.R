# -----------------------------------
# 📦 Chargement des bibliothèques
# -----------------------------------
packages <- c("tidyverse", "naniar", "DataExplorer", "ggplot2")
installed <- packages %in% rownames(installed.packages())
if (any(!installed)) {
  install.packages(packages[!installed])
}

library(tidyverse)
library(naniar)
library(ggplot2)
library(DataExplorer)

# -----------------------------------
# 📁 Création du dossier pour les figures
# -----------------------------------
if (!dir.exists("figures")) dir.create("figures")

# -----------------------------------
# 📂 Chargement des données brutes
# -----------------------------------
file_path <- "datasets/healthcare-dataset-stroke-data.csv"
stroke_data <- read_csv(file_path)

rows_before <- nrow(stroke_data)
stroke_data <- stroke_data %>% select(-id)
stroke_data <- stroke_data %>% mutate_if(is.character, as.factor)
stroke_data$bmi <- as.numeric(as.character(stroke_data$bmi))
stroke_data$stroke <- as.factor(stroke_data$stroke)

# -----------------------------------
# 📊 Visualisation des longueurs (avant nettoyage)
# -----------------------------------
non_na_counts <- stroke_data %>%
  summarise(across(everything(), ~ sum(!is.na(.)))) %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "non_na_count")

total_rows <- nrow(stroke_data)

non_na_counts <- non_na_counts %>%
  mutate(has_na = if_else(non_na_count < total_rows, TRUE, FALSE))

png("figures/longueurs_variables_avant_nettoyage.png", width = 1000, height = 600)
ggplot(non_na_counts, aes(x = reorder(variable, -non_na_count), y = non_na_count, fill = has_na)) +
  geom_bar(stat = "identity", width = 0.7) +
  scale_fill_manual(values = c("FALSE" = "gray40", "TRUE" = "#FF4B7D")) +
  labs(title = "Longueur de chaque variable (avant nettoyage)",
       subtitle = paste0("Nombre total de lignes : ", total_rows),
       x = "Variable", y = "Non NA", fill = "Manquantes ?") +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()

# -----------------------------------
# 🧹 Nettoyage
# -----------------------------------
stroke_data_clean <- stroke_data %>% drop_na() %>% distinct()
n_duplicates <- nrow(stroke_data_clean) - nrow(distinct(stroke_data_clean))
rows_after <- nrow(stroke_data_clean)

cat("📋 Lignes avant nettoyage:", rows_before, "\n")
cat("📋 Lignes après nettoyage:", rows_after, "\n")
cat("❌ Doublons supprimés:", n_duplicates, "\n")

# -----------------------------------
# 💾 Sauvegarde des données nettoyées
# -----------------------------------
saveRDS(stroke_data_clean, "datasets/stroke_data_clean.rds")
write_csv(stroke_data_clean, "datasets/stroke_data_clean.csv")  # Optionnel

# -----------------------------------
# 📸 Visualisation après nettoyage
# -----------------------------------
png("figures/valeurs_manquantes_apres_nettoyage.png", width = 1000, height = 600)
gg_miss_var(stroke_data_clean) +
  labs(title = "Valeurs manquantes après nettoyage",
       x = "Variable", y = "Nombre de valeurs manquantes") +
  theme_minimal(base_size = 14)
dev.off()

non_na_counts_clean <- stroke_data_clean %>%
  summarise(across(everything(), ~ sum(!is.na(.)))) %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "non_na_count") %>%
  mutate(has_na = if_else(non_na_count < rows_after, TRUE, FALSE))

png("figures/longueurs_variables_apres_nettoyage.png", width = 1000, height = 600)
ggplot(non_na_counts_clean, aes(x = reorder(variable, -non_na_count), y = non_na_count, fill = has_na)) +
  geom_bar(stat = "identity", width = 0.7) +
  scale_fill_manual(values = c("FALSE" = "gray40", "TRUE" = "#FF4B7D")) +
  labs(title = "Longueur de chaque variable (après nettoyage)",
       subtitle = paste0("Nombre total de lignes : ", rows_after),
       x = "Variable", y = "Non NA", fill = "Manquantes ?") +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()















# # -----------------------------------
# # 📦 Chargement des bibliothèques (installer si nécessaire)
# # -----------------------------------
# packages <- c("tidyverse", "naniar", "DataExplorer", "ggplot2")
# installed <- packages %in% rownames(installed.packages())
# if (any(!installed)) {
#   install.packages(packages[!installed])
# }
# 
# library(tidyverse)
# library(naniar)
# library(ggplot2)
# library(DataExplorer)
# 
# # -----------------------------------
# # 📁 Création du dossier pour les figures
# # -----------------------------------
# if (!dir.exists("figures")) dir.create("figures")
# 
# # -----------------------------------
# # 📂 Chargement des données
# # -----------------------------------
# file_path <- "datasets/healthcare-dataset-stroke-data.csv"
# stroke_data <- read_csv(file_path)
# 
# # Sauvegarde du nombre de lignes avant nettoyage
# rows_before <- nrow(stroke_data)
# print(paste("Lignes avant nettoyage:", rows_before))
# 
# # Aperçu des données et suppression de la colonne inutile
# glimpse(stroke_data)
# stroke_data <- stroke_data %>% select(-id)
# 
# # Conversion des variables caractères en facteurs
# stroke_data <- stroke_data %>% mutate_if(is.character, as.factor)
# 
# # Conversion de la variable 'bmi' en numérique (gère "N/A" en tant que NA)
# stroke_data$bmi <- as.numeric(as.character(stroke_data$bmi))
# sum(is.na(stroke_data$bmi))  # Affiche le nombre de valeurs manquantes pour 'bmi'
# 
# # Conversion de la variable 'stroke' en facteur
# stroke_data$stroke <- as.factor(stroke_data$stroke)
# 
# # -----------------------------------
# # 📊 Visualisation des longueurs des variables et valeurs manquantes (avant nettoyage)
# # -----------------------------------
# non_na_counts <- stroke_data %>%
#   summarise(across(everything(), ~ sum(!is.na(.)))) %>%
#   pivot_longer(cols = everything(), names_to = "variable", values_to = "non_na_count")
# 
# total_rows <- nrow(stroke_data)
# 
# non_na_counts <- non_na_counts %>%
#   mutate(has_na = if_else(non_na_count < total_rows, TRUE, FALSE))
# 
# png("figures/longueurs_variables_avant_nettoyage.png", width = 1000, height = 600)
# ggplot(non_na_counts, aes(x = reorder(variable, -non_na_count), y = non_na_count, fill = has_na)) +
#   geom_bar(stat = "identity", width = 0.7) +
#   scale_fill_manual(values = c("FALSE" = "gray40", "TRUE" = "#FF4B7D")) +
#   labs(title = "Longueur de chaque variable (avant nettoyage)",
#        subtitle = paste0("Nombre total de lignes : ", total_rows, " — Variables avec valeurs manquantes en rouge"),
#        x = "Variable",
#        y = "Nombre de valeurs non manquantes",
#        fill = "Manquantes ?") +
#   theme_minimal(base_size = 14) +
#   theme(axis.text.x = element_text(angle = 45, hjust = 1))
# dev.off()
# 
# # -----------------------------------
# # 🦼️ Nettoyage des données (suppression des valeurs manquantes et doublons)
# # -----------------------------------
# stroke_data_clean <- stroke_data %>% drop_na()
# duplicates <- stroke_data_clean[duplicated(stroke_data_clean), ]
# n_duplicates <- nrow(duplicates)
# stroke_data_clean <- stroke_data_clean %>% distinct()
# 
# rows_after <- nrow(stroke_data_clean)
# 
# # Affichage des infos de nettoyage
# cat("\ud83d\udccb Lignes avant nettoyage:", rows_before, "\n")
# cat("\ud83d\udccb Lignes après nettoyage:", rows_after, "\n")
# cat("\u274c Doublons supprimés:", n_duplicates, "\n")
# 
# # -----------------------------------
# # 🔍 Résumé des valeurs manquantes (après nettoyage)
# # -----------------------------------
# missing_values_clean <- colSums(is.na(stroke_data_clean))
# print(missing_values_clean)
# 
# # -----------------------------------
# # 📸 Sauvegarde de la visualisation des valeurs manquantes (après nettoyage)
# # -----------------------------------
# png("figures/valeurs_manquantes_apres_nettoyage.png", width = 1000, height = 600)
# gg_miss_var(stroke_data_clean) +
#   labs(title = "Valeurs manquantes après nettoyage",
#        subtitle = paste0("Nombre total de lignes : ", rows_after, " — Aucune valeur manquante"),
#        x = "Variable",
#        y = "Nombre de valeurs manquantes") +
#   theme_minimal(base_size = 14)
# dev.off()
# 
# # -----------------------------------
# # 📊 Longueur des variables après nettoyage
# # -----------------------------------
# non_na_counts_clean <- stroke_data_clean %>%
#   summarise(across(everything(), ~ sum(!is.na(.)))) %>%
#   pivot_longer(cols = everything(), names_to = "variable", values_to = "non_na_count") %>%
#   mutate(has_na = if_else(non_na_count < rows_after, TRUE, FALSE))
# 
# png("figures/longueurs_variables_apres_nettoyage.png", width = 1000, height = 600)
# ggplot(non_na_counts_clean, aes(x = reorder(variable, -non_na_count), y = non_na_count, fill = has_na)) +
#   geom_bar(stat = "identity", width = 0.7) +
#   scale_fill_manual(values = c("FALSE" = "gray40", "TRUE" = "#FF4B7D")) +
#   labs(title = "Longueur de chaque variable (après nettoyage)",
#        subtitle = paste0("Nombre total de lignes : ", rows_after, " — Aucune valeur manquante"),
#        x = "Variable",
#        y = "Nombre de valeurs non manquantes",
#        fill = "Manquantes ?") +
#   theme_minimal(base_size = 14) +
#   theme(axis.text.x = element_text(angle = 45, hjust = 1))
# dev.off()
# 
# 
# 
# 
# 
# 




# # -----------------------------------
# # 📦 Load Libraries (Install if Needed)
# # -----------------------------------
# packages <- c("tidyverse", "naniar", "DataExplorer", "ggplot2")
# installed <- packages %in% rownames(installed.packages())
# if (any(!installed)) {
#   install.packages(packages[!installed])
# }
# 
# library(tidyverse)
# library(naniar)
# library(ggplot2)
# library(DataExplorer)
# 
# # -----------------------------------
# # 📁 Create folder for figures
# # -----------------------------------
# if (!dir.exists("figures")) dir.create("figures")
# 
# # -----------------------------------
# 
# # -----------------------------------
# # 📂 Load Data
# # -----------------------------------
# file_path <- "datasets/healthcare-dataset-stroke-data.csv"
# stroke_data <- read_csv(file_path)
# 
# # -----------------------------------
# 
# # Save row count before cleaning
# rows_before <- nrow(stroke_data)
# print(paste("Rows before cleaning:", rows_before))
# # -----------------------------------
# 
# # 👁️ Glimpse and Drop Useless Columns
# # -----------------------------------
# glimpse(stroke_data)
# stroke_data <- stroke_data %>% select(-id)
# 
# # -----------------------------------
# # Convert character columns to factors
# stroke_data <- stroke_data %>% mutate_if(is.character, as.factor)
# 
# # Convert BMI from character to numeric (handles "N/A" as NA)
# stroke_data$bmi <- as.numeric(as.character(stroke_data$bmi))
# sum(is.na(stroke_data$bmi))  # → te donne le nombre de BMI manquants
# 
# # Convert stroke to factor
# stroke_data$stroke <- as.factor(stroke_data$stroke)
# # -----------------------------------
# # 📊 Visualize Variable Lengths and Highlight Missing
# # -----------------------------------
# 
# # Count non-NA values per column
# non_na_counts <- stroke_data %>%
#   summarise(across(everything(), ~ sum(!is.na(.)))) %>%
#   pivot_longer(cols = everything(), names_to = "variable", values_to = "non_na_count")
# 
# # Total row count (max possible per variable)
# total_rows <- nrow(stroke_data)
# 
# # Add a column to flag if there's missing data
# non_na_counts <- non_na_counts %>%
#   mutate(has_na = if_else(non_na_count < total_rows, TRUE, FALSE))
# 
# # Plot with colors for missing
# png("figures/variable_lengths_highlight_missing.png", width = 1000, height = 600)
# ggplot(non_na_counts, aes(x = reorder(variable, -non_na_count), y = non_na_count, fill = has_na)) +
#   geom_bar(stat = "identity", width = 0.7) +
#   scale_fill_manual(values = c("FALSE" = "gray40", "TRUE" = "#FF4B7D")) +
#   labs(title = "Length of Each Variable (Before Cleaning)",
#        subtitle = paste0("Total rows: ", total_rows, " — Variables with missing values in red"),
#        x = "Variable",
#        y = "Non-missing Count",
#        fill = "Missing?") +
#   theme_minimal(base_size = 14) +
#   theme(axis.text.x = element_text(angle = 45, hjust = 1))
# dev.off()
# # -----------------------------------
# 
# # -----------------------------------
# # 🧼 Clean Data (Drop Missing and Duplicates)
# # -----------------------------------
# stroke_data_clean <- stroke_data %>% drop_na()
# duplicates <- stroke_data_clean[duplicated(stroke_data_clean), ]
# n_duplicates <- nrow(duplicates)
# stroke_data_clean <- stroke_data_clean %>% distinct()
# 
# rows_after <- nrow(stroke_data_clean)
# 
# # -----------------------------------
# 
# # print nb of rows before and after cleaning
# cat("🧾 Rows before cleaning:", rows_before, "\n")
# cat("🧾 Rows after cleaning :", rows_after, "\n")
# cat("❌ Duplicates removed  :", n_duplicates, "\n")
# 
# # -----------------------------------
# # 🔍 Missing Value Summary (After Cleaning)
# # -----------------------------------
# missing_values_clean <- colSums(is.na(stroke_data_clean))
# print(missing_values_clean)
# 
# # -----------------------------------
# 
# # 📸 Save Missing Values Plot (After)
# png("figures/missing_values_after_cleaning.png", width = 1000, height = 600)
# gg_miss_var(stroke_data_clean) +
#   labs(title = "Missing Values After Cleaning",
#        subtitle = paste0("Total rows: ", rows_after, " — No missing values"),
#        x = "Variable",
#        y = "Missing Count") +
#   theme_minimal(base_size = 14)
# dev.off()
# 
# # -----------------------------------
# # -----------------------------------
# # 📊 Variable Lengths After Cleaning (Highlight None Missing in Red if Any)
# # -----------------------------------
# # Recalculate non-missing values for the cleaned dataset
# non_na_counts_clean <- stroke_data_clean %>%
#   summarise(across(everything(), ~ sum(!is.na(.)))) %>%
#   pivot_longer(cols = everything(), names_to = "variable", values_to = "non_na_count")
# 
# # # Add missing flag
# # non_na_counts_clean <- non_na_counts_clean %>%
# #   mutate(has_na = if_else(non_na_count < rows_after, TRUE, FALSE))
# 
# # Plot
# png("figures/variable_lengths_after_cleaning.png", width = 1000, height = 600)
# ggplot(non_na_counts_clean, aes(x = reorder(variable, -non_na_count), y = non_na_count, fill = has_na)) +
#   geom_bar(stat = "identity", width = 0.7) +
#   scale_fill_manual(values = c("FALSE" = "gray40", "TRUE" = "#FF4B7D")) +
#   labs(title = "Length of Each Variable (After Cleaning)",
#        subtitle = paste0("Total rows: ", rows_after, " — No variables with missing values"),
#        x = "Variable",
#        y = "Non-missing Count",
#        fill = "Missing?") +
#   theme_minimal(base_size = 14) +
#   theme(axis.text.x = element_text(angle = 45, hjust = 1))
# dev.off()
# # -----------------------------------
# 
# 
# 
# 
# 
# 
# 
