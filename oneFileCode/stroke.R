# -----------------------------------
# 📦 Chargement des bibliothèques
# -----------------------------------
packages <- c("tidyverse","tidymodels", "naniar", "DataExplorer", "ggplot2","rlang","GGally","corrplot","dplyr" , "e1071", "randomForest", "rpart", "xgboost", "ROSE", "pROC", "MLmetrics")
installed <- packages %in% rownames(installed.packages())
if (any(!installed)) {
  install.packages(packages[!installed])
}
library(dplyr)
library(tidyverse)
library(readr)
library(tidymodels)
library(naniar)
library(ggplot2)
library(DataExplorer)
library(GGally)   # pour ggpairs
library(corrplot) # pour matrice de corrélation
library(caret)
library(e1071)          # Naive Bayes & SVM
library(rpart)          # Arbre de décision
library(randomForest)   # Random Forest
library(pROC)           # AUC/ROC
library(MLmetrics)      # F1 Score



# -----------------------------------
# 📁 Création du dossier pour les figures
# -----------------------------------
if (!dir.exists("oneFileCode/figures")) dir.create("oneFileCode/figures")

# -----------------------------------
# 📂 Chargement des données brutes
# -----------------------------------
file_path <- "datasets/healthcare-dataset-stroke-data.csv"
stroke_data <- read_csv(file_path)

# Sauvegarde du nombre de lignes avant nettoyage
rows_before <- nrow(stroke_data)

# Suppression de la colonne ID et conversion des types
stroke_data <- stroke_data %>%
  select(-id) %>%
  mutate(across(where(is.character), as.factor),
         bmi = as.numeric(as.character(bmi)),
         stroke = as.factor(stroke))

# -----------------------------------
# 📊 Visualisation des valeurs non manquantes (avant nettoyage)
# -----------------------------------
rows_before <- nrow(stroke_data)

non_na_counts <- stroke_data %>%
  summarise(across(everything(), ~sum(!is.na(.)))) %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "non_na_count") %>%
  mutate(
    na_count = rows_before - non_na_count,
    na_percent = round(100 * na_count / rows_before, 1),
    has_na = na_count > 0
  )


png("oneFileCode/figures/longueurs_variables_avant_nettoyage.png", width = 1200, height = 800)
ggplot(non_na_counts, aes(x = reorder(variable, -non_na_count), y = non_na_count, fill = has_na)) +
  geom_bar(stat = "identity", width = 0.7) +
  geom_text(aes(label = ifelse(has_na, paste0("NA: ", na_count, "\n(", na_percent, "%)"), "")),
            vjust = -0.5, size = 4.2, color = "black") +
  scale_fill_manual(values = c("FALSE" = "gray40", "TRUE" = "#FF4B7D")) +
  labs(title = "Longueur de chaque variable (avant nettoyage)",
       subtitle = paste0("Nombre total de lignes : ", rows_before),
       x = "Variable", y = "Valeurs non manquantes", fill = "Manquantes ?") +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

dev.off()



# -----------------------------------
# 🧹 Nettoyage des données
# -----------------------------------
stroke_data_clean <- stroke_data %>%
  drop_na() %>%
  distinct()

rows_after <- nrow(stroke_data_clean)
n_duplicates <- rows_before - nrow(distinct(stroke_data))

cat("📋 Lignes avant nettoyage:", rows_before, "\n")
cat("📋 Lignes après nettoyage:", rows_after, "\n")
cat("❌ Doublons supprimés:", n_duplicates, "\n")

# -----------------------------------
# 💾 Sauvegarde des données nettoyées
# -----------------------------------
saveRDS(stroke_data_clean, "datasets/stroke_data_clean.rds") # Export RDS 
write_csv(stroke_data_clean, "datasets/stroke_data_clean.csv")  # Export optionnel

# -----------------------------------
# 📸 Visualisation après nettoyage
# -----------------------------------

rows_after <- nrow(stroke_data_clean)

non_na_counts_after <- stroke_data_clean %>%
  summarise(across(everything(), ~sum(!is.na(.)))) %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "non_na_count") %>%
  mutate(
    na_count = rows_after - non_na_count,
    na_percent = round(100 * na_count / rows_after, 1),
    has_na = na_count > 0
  )

# 1. Valeurs manquantes
png("oneFileCode/figures/valeurs_manquantes_apres_nettoyage.png", width = 1200, height = 800)

ggplot(non_na_counts_after, aes(x = reorder(variable, -non_na_count), y = non_na_count, fill = has_na)) +
  geom_bar(stat = "identity", width = 0.7) +
  geom_text(aes(label = ifelse(has_na, paste0("NA: ", na_count, "\n(", na_percent, "%)"), "")),
            vjust = -0.5, size = 4.2, color = "black") +
  scale_fill_manual(values = c("FALSE" = "gray40", "TRUE" = "#FF4B7D")) +
  labs(title = "Longueur de chaque variable (après nettoyage)",
       subtitle = paste0("Nombre total de lignes : ", rows_after),
       x = "Variable", y = "Valeurs non manquantes", fill = "Manquantes ?") +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

dev.off()


# 2. Longueurs des variables après nettoyage
non_na_counts_clean <- stroke_data_clean %>%
  summarise(across(everything(), ~ sum(!is.na(.)))) %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "non_na_count") %>%
  mutate(has_na = non_na_count < rows_after)

png("oneFileCode/figures/longueurs_variables_apres_nettoyage.png", width = 1000, height = 600)
ggplot(non_na_counts_clean, aes(x = reorder(variable, -non_na_count), y = non_na_count, fill = has_na)) +
  geom_bar(stat = "identity", width = 0.7) +
  scale_fill_manual(values = c("FALSE" = "gray40", "TRUE" = "#FF4B7D")) +
  labs(title = "Longueur de chaque variable (après nettoyage)",
       subtitle = paste0("Nombre total de lignes : ", rows_after),
       x = "Variable", y = "Valeurs non manquantes", fill = "Manquantes ?") +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()

# -----------------------------------
       # end nettoyage space
# -----------------------------------

# -------------------------------------------

    # 📊 Visualisation des données (eda)

# ------------------------------------------


# Transformation des variables catégorielles en facteurs
stroke_data <- stroke_data_clean %>%
  mutate(
    gender = factor(gender),
    ever_married = factor(ever_married),
    work_type = factor(work_type),
    Residence_type = factor(Residence_type),
    smoking_status = factor(smoking_status),
    hypertension = factor(hypertension, levels = c(0, 1), labels = c("No", "Yes")),
    heart_disease = factor(heart_disease, levels = c(0, 1), labels = c("No", "Yes")),
    stroke = factor(stroke, levels = c(0, 1), labels = c("No Stroke", "Stroke"))
  )

# visualisation de variable cible (stroke) en pourcentage 
png("oneFileCode/figures/variable_cible.png", width = 1200, height = 800)
ggplot(stroke_data, aes(x = "", fill = stroke)) +
  geom_bar(width = 1, color = "white") +
  coord_polar(theta = "y") +
  geom_text(stat = "count", aes(label = paste0(round((..count..)/sum(..count..) * 100, 1), "%")),
            position = position_stack(vjust = 0.5), size = 5) +
  scale_fill_manual(values = c("No Stroke" = "#0072B2", "Stroke" = "#FF4B7D")) +
  labs(title = "Distribution de la variable cible (Stroke)",
       x = "", y = "") +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())
dev.off()
# 📊 Visualisation de la variable cible (stroke) en barres
png("oneFileCode/figures/variable_cible_bar.png", width = 1200, height = 800)
ggplot(stroke_data, aes(x = stroke, fill = stroke)) +
  geom_bar(width = 0.7) +
  scale_fill_manual(values = c("No Stroke" = "#0072B2", "Stroke" = "#FF4B7D")) +
  labs(title = "Distribution de la variable cible (Stroke)",
       x = "Stroke", y = "Count") +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(size = 12),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14))
dev.off()

# visualisation des variables continues en seul figure

# 📊 Sélectionner les variables continues
numeric_vars <- stroke_data %>% select_if(is.numeric)
# 📐 Transformer au format long pour ggplot
long_numeric <- numeric_vars %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "value")
# 📊 Créer le graphique
png("oneFileCode/figures/variables_continues.png", width = 1200, height = 800)

ggplot(long_numeric, aes(x = value)) +
  geom_histogram(bins = 30, fill = "#0072B2", color = "white") +
  facet_wrap(~ variable, scales = "free", ncol = 2) +
  labs(title = "Distribution des variables continues",
       x = "Valeur", y = "Fréquence") +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5), # titre centré
    axis.title = element_text(size = 14),   # titres des axes
    axis.text = element_text(size = 12),    # valeurs des axes
    strip.text = element_text(size = 16, face = "bold", color = "navyblue"), # titres des petits graphiques
    panel.spacing = unit(2, "lines"),       # espace entre les facets
    panel.grid.major = element_line(color = "grey80"), # grille plus douce
    panel.grid.minor = element_blank()       # enlever petites grilles inutiles
  )

dev.off()

# boite à moustaches pour les variables continues
png("oneFileCode/figures/boite_moustaches.png", width = 1200, height = 800)
ggplot(long_numeric, aes(x = variable, y = value)) +
  geom_boxplot(fill = "#56B4E9", color = "black", outlier.color = "red", outlier.size = 2) +
  labs(
    title = "Boîte à moustaches des variables continues",
    x = "Variable",
    y = "Valeur"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )
dev.off()
# count outliers 
outliers <- long_numeric %>%
  group_by(variable) %>%
  summarise(outliers = sum(value < quantile(value, 0.25) - 1.5 * IQR(value) | value > quantile(value, 0.75) + 1.5 * IQR(value)))


# 📊 Visualisation des variables catégorielles (avec pourcentage)

# 📁 Sélection des variables catégorielles
categorical_vars <- stroke_data %>% select(where(is.factor))

# 📐 Transformation au format long
long_categorical <- categorical_vars %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "value") %>%
  group_by(variable, value) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(variable) %>%
  mutate(percentage = round(100 * count / sum(count), 1))

# 📊 Création du graphique
png("oneFileCode/figures/variables_categorielles.png", width = 1400, height = 1000)

ggplot(long_categorical, aes(x = value, y = percentage, fill = value)) +
  geom_bar(stat = "identity", width = 0.9, show.legend = FALSE) +
  geom_text(aes(label = paste0(percentage, "%")), vjust = 0.5, size = 4) +
  facet_wrap(~ variable, scales = "free", ncol = 2) +
  labs(title = "Distribution des variables catégorielles",
       x = "", y = "Pourcentage") +
  theme_minimal(base_size = 14) +
  theme(
    strip.text = element_text(size = 14, face = "bold", color = "#0072B2"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

dev.off()


# 📊 analyse bivariée entre chaque variable  et la variable cible (stroke)

 # age vs stroke
png("oneFileCode/figures/age_vs_stroke.png", width = 1200, height = 800)

ggplot(stroke_data, aes(x = age, fill = stroke)) +
  geom_histogram(bins = 30, position = "dodge", alpha = 0.8, color = "white") +
  scale_fill_manual(
    values = c("No Stroke" = "#0072B2", "Stroke" = "red"),
    labels = c("Aucun AVC", "AVC")
  ) +
  labs(
    title = "Distribution de l'âge selon la variable AVC",
    x = "Âge", y = "Nombre de cas", fill = "Statut AVC"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold"),
    legend.title = element_text(size = 13),
    legend.text = element_text(size = 12)
  )

dev.off()

# bmi vs stroke 
png("oneFileCode/figures/bmi_vs_stroke.png", width = 1200, height = 800)
ggplot(stroke_data, aes(x = bmi, fill = stroke)) +
  geom_histogram(bins = 30, position = "dodge", alpha = 0.8, color = "white") +
  scale_fill_manual(
    values = c("No Stroke" = "#0072B2", "Stroke" = "red"),
    labels = c("Aucun AVC", "AVC")
  ) +
  labs(
    title = "Distribution de l'IMC selon la variable AVC",
    x = "IMC", y = "Nombre de cas", fill = "Statut AVC"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold"),
    legend.title = element_text(size = 13),
    legend.text = element_text(size = 12)
  )
dev.off()

# avg_glucose_level vs stroke 
png("oneFileCode/figures/avg_glucose_level_vs_stroke.png", width = 1200, height = 800)
ggplot(stroke_data, aes(x = avg_glucose_level, fill = stroke)) +
  geom_histogram(bins = 30, position = "dodge", alpha = 0.8, color = "white") +
  scale_fill_manual(
    values = c("No Stroke" = "#0072B2", "Stroke" = "red"),
    labels = c("Aucun AVC", "AVC")
  ) +
  labs(
    title = "Distribution du taux de glucose selon la variable AVC",
    x = "Taux de glucose", y = "Nombre de cas", fill = "Statut AVC"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold"),
    legend.title = element_text(size = 13),
    legend.text = element_text(size = 12)
  )
dev.off()


# Hypertension vs AVC  

hypertension_counts <- stroke_data %>%
  group_by(hypertension, stroke) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(hypertension) %>%
  mutate(percentage = round(100 * count / sum(count), 1))

# Save the figure
png("oneFileCode/figures/hypertension_vs_stroke.png", width = 1200, height = 800)

# Create the plot
ggplot(hypertension_counts, aes(x = hypertension, y = percentage, fill = stroke)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white", alpha = 0.9) +
  geom_text(
    aes(label = paste0(percentage, "%")), 
    position = position_dodge(width = 0.7), 
    vjust = -0.5, 
    size = 6,                   # Slightly larger text
    color = "black",            # High contrast
    fontface = "bold"           # Make text bold
  ) +
  scale_fill_manual(values = c("No Stroke" = "#0072B2", "Stroke" = "red")) +
  labs(
    title = "Répartition des cas d'AVC selon l'hypertension",
    x = "Hypertension", y = "Pourcentage (%)", fill = "Statut AVC"
  ) +
  ylim(0, max(hypertension_counts$percentage) + 10) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold"),
    legend.title = element_text(size = 13),
    legend.text = element_text(size = 12)
  )

dev.off()

# Heart disease vs stroke
heart_disease_counts <- stroke_data %>%
  group_by(heart_disease, stroke) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(heart_disease) %>%
  mutate(percentage = round(100 * count / sum(count), 1))
# Save the figure
png("oneFileCode/figures/heart_disease_vs_stroke.png", width = 1200, height = 800)
# Create the plot
ggplot(heart_disease_counts, aes(x = heart_disease, y = percentage, fill = stroke)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white", alpha = 0.9) +
  geom_text(
    aes(label = paste0(percentage, "%")), 
    position = position_dodge(width = 0.7), 
    vjust = -0.5, 
    size = 6,                   # Slightly larger text
    color = "black",            # High contrast
    fontface = "bold"           # Make text bold
  ) +
  scale_fill_manual(values = c("No Stroke" = "#0072B2", "Stroke" = "red")) +
  labs(
    title = "Répartition des cas d'AVC selon les maladies cardiaques",
    x = "Maladie cardiaque", y = "Pourcentage (%)", fill = "Statut AVC"
  ) +
  ylim(0, max(heart_disease_counts$percentage) + 10) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold"),
    legend.title = element_text(size = 13),
    legend.text = element_text(size = 12)
  )
dev.off()
# statut tabagique vs stroke
smoking_counts <- stroke_data %>%
  group_by(smoking_status, stroke) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(smoking_status) %>%
  mutate(percentage = round(100 * count / sum(count), 1))
# Save the figure
png("oneFileCode/figures/smoking_status_vs_stroke.png", width = 1200, height = 800)
# Create the plot
ggplot(smoking_counts, aes(x = smoking_status, y = percentage, fill = stroke)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white", alpha = 0.9) +
  geom_text(
    aes(label = paste0(percentage, "%")), 
    position = position_dodge(width = 0.7), 
    vjust = -0.5, 
    size = 6,                   # Slightly larger text
    color = "black",            # High contrast
    fontface = "bold"           # Make text bold
  ) +
  scale_fill_manual(values = c("No Stroke" = "#0072B2", "Stroke" = "red")) +
  labs(
    title = "Répartition des cas d'AVC selon le statut tabagique",
    x = "Statut tabagique", y = "Pourcentage (%)", fill = "Statut AVC"
  ) +
  ylim(0, max(smoking_counts$percentage) + 10) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold"),
    legend.title = element_text(size = 13),
    legend.text = element_text(size = 12)
  )
dev.off()

# residence type vs stroke
residence_counts <- stroke_data %>%
  group_by(Residence_type, stroke) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(Residence_type) %>%
  mutate(percentage = round(100 * count / sum(count), 1))
# Save the figure
png("oneFileCode/figures/residence_type_vs_stroke.png", width = 1200, height = 800)
# Create the plot
ggplot(residence_counts, aes(x = Residence_type, y = percentage, fill = stroke)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white", alpha = 0.9) +
  geom_text(
    aes(label = paste0(percentage, "%")), 
    position = position_dodge(width = 0.7), 
    vjust = -0.5, 
    size = 6,                   # Slightly larger text
    color = "black",            # High contrast
    fontface = "bold"           # Make text bold
  ) +
  scale_fill_manual(values = c("No Stroke" = "#0072B2", "Stroke" = "red")) +
  labs(
    title = "Répartition des cas d'AVC selon le type de résidence",
    x = "Type de résidence", y = "Pourcentage (%)", fill = "Statut AVC"
  ) +
  ylim(0, max(residence_counts$percentage) + 10) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold"),
    legend.title = element_text(size = 13),
    legend.text = element_text(size = 12)
  )
dev.off()

# work type vs stroke
work_counts <- stroke_data %>%
  group_by(work_type, stroke) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(work_type) %>%
  mutate(percentage = round(100 * count / sum(count), 1))
# Save the figure
png("oneFileCode/figures/work_type_vs_stroke.png", width = 1200, height = 800)
# Create the plot
ggplot(work_counts, aes(x = work_type, y = percentage, fill = stroke)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white", alpha = 0.9) +
  geom_text(
    aes(label = paste0(percentage, "%")), 
    position = position_dodge(width = 0.7), 
    vjust = -0.5, 
    size = 6,                   # Slightly larger text
    color = "black",            # High contrast
    fontface = "bold"           # Make text bold
  ) +
  scale_fill_manual(values = c("No Stroke" = "#0072B2", "Stroke" = "red")) +
  labs(
    title = "Répartition des cas d'AVC selon le type de travail",
    x = "Type de travail", y = "Pourcentage (%)", fill = "Statut AVC"
  ) +
  ylim(0, max(work_counts$percentage) + 10) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold"),
    legend.title = element_text(size = 13),
    legend.text = element_text(size = 12)
  )
dev.off()

# statut marital vs stroke
marital_counts <- stroke_data %>%
  group_by(ever_married, stroke) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(ever_married) %>%
  mutate(percentage = round(100 * count / sum(count), 1))
# Save the figure
png("oneFileCode/figures/marital_status_vs_stroke.png", width = 1200, height = 800)
# Create the plot
ggplot(marital_counts, aes(x = ever_married, y = percentage, fill = stroke)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white", alpha = 0.9) +
  geom_text(
    aes(label = paste0(percentage, "%")), 
    position = position_dodge(width = 0.7), 
    vjust = -0.5, 
    size = 6,                   # Slightly larger text
    color = "black",            # High contrast
    fontface = "bold"           # Make text bold
  ) +
  scale_fill_manual(values = c("No Stroke" = "#0072B2", "Stroke" = "red")) +
  labs(
    title = "Répartition des cas d'AVC selon le statut marital",
    x = "Statut marital", y = "Pourcentage (%)", fill = "Statut AVC"
  ) +
  ylim(0, max(marital_counts$percentage) + 10) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold"),
    legend.title = element_text(size = 13),
    legend.text = element_text(size = 12)
  )
dev.off()

# gender vs stroke 

gender_counts <- stroke_data %>%
  group_by(gender, stroke) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(gender) %>%
  mutate(percentage = round(100 * count / sum(count), 1))

# Save the figure
png("oneFileCode/figures/gender_vs_stroke.png", width = 1200, height = 800)
# Create the plot
ggplot(gender_counts, aes(x = gender, y = percentage, fill = stroke)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white", alpha = 0.9) +
  geom_text(
    aes(label = paste0(percentage, "%")), 
    position = position_dodge(width = 0.7), 
    vjust = -0.5, 
    size = 6,                   # Slightly larger text
    color = "black",            # High contrast
    fontface = "bold"           # Make text bold
  ) +
  scale_fill_manual(values = c("No Stroke" = "#0072B2", "Stroke" = "red")) +
  labs(
    title = "Répartition des cas d'AVC selon genre",
    x = "genre", y = "Pourcentage (%)", fill = "Statut AVC"
  ) +
  ylim(0, max(gender_counts$percentage) + 10) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold"),
    legend.title = element_text(size = 13),
    legend.text = element_text(size = 12)
  )
dev.off()

# 📊 Matrice de corrélation entre les variables continues
# Sélectionner les variables continues
numeric_vars <- stroke_data %>% select_if(is.numeric)
# Matrice de corrélation claire
png("oneFileCode/figures/matrice_correlation.png", width = 1200, height = 800)
corr_matrix <- cor(numeric_vars, use = "pairwise.complete.obs")
corrplot(corr_matrix, method = "circle", type = "upper", tl.col = "black",
         tl.srt = 45, addCoef.col = "black", number.cex = 0.7,
         title = "Matrice de corrélation entre les variables continues",
         mar = c(0, 0, 2, 0), cl.lim = c(-1, 1), cl.ratio = 0.2)
dev.off()
# nuage de points entre age et bmi (stroke non et stroke oui avec shape different)
png("oneFileCode/figures/age_vs_bmi.png", width = 1200, height = 800)
ggplot(stroke_data, aes(x = age, y = bmi, color = stroke, shape = stroke)) +
  geom_point(alpha = 0.7, size = 3) +
  scale_color_manual(values = c("No Stroke" = "#454545", "Stroke" = "red")) +
  scale_shape_manual(values = c(16, 17)) + # Circle for No Stroke, Triangle for Stroke
  labs(title = "Nuage de points entre l'âge et l'IMC",
       x = "Âge", y = "IMC", color = "Statut AVC", shape = "Statut AVC") +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold"),
    legend.title = element_text(size = 13),
    legend.text = element_text(size = 12)
  )
dev.off()

# Models 

#  origin destrubition #

set.seed(123)
index <- createDataPartition(stroke_data$stroke, p = 0.8, list = FALSE)
train_data <- stroke_data[index, ]
test_data  <- stroke_data[-index, ]

# proportions naturelles
prop.table(table(train_data$stroke)) * 100
prop.table(table(test_data$stroke)) * 100
# Function to evaluate model performance
evaluate_model <- function(model, test_data, model_name) {
  pred <- predict(model, newdata = test_data)
  
  # Confusion matrix
  cm <- confusionMatrix(pred, test_data$stroke)
  
  # AUC
  roc_obj <- roc(as.numeric(test_data$stroke), as.numeric(pred))
  auc_val <- auc(roc_obj)
  
  # F1-score
  f1 <- F1_Score(pred, test_data$stroke, positive = "Stroke")
  
  cat("\n---", model_name, "---\n")
  print(cm)
  cat("AUC:", auc_val, "\n")
  cat("F1 Score:", f1, "\n")
  
  return(list(
    Accuracy = cm$overall["Accuracy"],
    Sensitivity = cm$byClass["Sensitivity"],
    Specificity = cm$byClass["Specificity"],
    F1 = f1,
    AUC = auc_val
  ))
}

# Logistic Regression
model_log <- train(stroke ~ ., data = train_data, method = "glm", family = "binomial")
results_log <- evaluate_model(model_log, test_data, "Régression Logistique")

# arbre de décision

model_tree <- train(stroke ~ ., data = train_data, method = "rpart")
results_tree <- evaluate_model(model_tree, test_data, "Arbre de Décision")
# Random Forest
model_rf <- train(stroke ~ ., data = train_data, method = "rf", ntree = 100)
results_rf <- evaluate_model(model_rf, test_data, "Random Forest")

# Naive Bayes


model_nb <- train(stroke ~ ., data = train_data, method = "naive_bayes")
results_nb <- evaluate_model(model_nb, test_data, "Naive Bayes")

#--------------------------Note --------------------------#
            # Les modèles à prédire la classe majoritaire (no Stroke) 
            # et ignorent la minoritaire (Stroke).
#--------------------------Note --------------------------#

#  1. Séparer train/test sans équilibrage
set.seed(123)
index <- createDataPartition(stroke_data$stroke, p = 0.8, list = FALSE)
train_raw <- stroke_data[index, ]
test_data <- stroke_data[-index, ]

# Vérif : proportions naturelles
prop.table(table(train_raw$stroke)) * 100
prop.table(table(test_data$stroke)) * 100

# 2. Équilibrer le TRAIN avec ROSE
set.seed(123)
library(ROSE)
train_bal <- ROSE(stroke ~ ., data = train_raw, seed = 1)$data
table(train_bal$stroke)  # Vérifie bien l’équilibre
prop.table(table(train_bal$stroke)) * 100  # Proportions du train eqi

#  3. Fonction pour entraîner, prédire et évaluer
evaluate_model <- function(model, test_data, model_name) {
  pred <- predict(model, newdata = test_data)
  cm <- confusionMatrix(pred, test_data$stroke)
  roc_obj <- roc(as.numeric(test_data$stroke), as.numeric(pred))
  auc_val <- auc(roc_obj)
  f1 <- F1_Score(pred, test_data$stroke, positive = "Stroke")
  
  cat("\n---", model_name, "---\n")
  print(cm)
  cat("AUC:", auc_val, "\n")
  cat("F1 Score:", f1, "\n")
  
  return(data.frame(
    Model = model_name,
    Accuracy = cm$overall["Accuracy"],
    Sensitivity = cm$byClass["Sensitivity"],
    Specificity = cm$byClass["Specificity"],
    F1 = f1,
    AUC = auc_val
  ))
}

#  4. Entraînement des modèles sur le TRAIN équilibré

# a) Régression logistique
model_log <- train(stroke ~ ., data = train_bal, method = "glm", family = "binomial")
res_log <- evaluate_model(model_log, test_data, "Régression Logistique")

# b) Arbre de décision
model_tree <- train(stroke ~ ., data = train_bal, method = "rpart")
res_tree <- evaluate_model(model_tree, test_data, "Arbre de Décision")

# c) Random Forest
model_rf <- train(stroke ~ ., data = train_bal, method = "rf", ntree = 100)
res_rf <- evaluate_model(model_rf, test_data, "Random Forest")

# d) Naive Bayes
model_nb <- train(stroke ~ ., data = train_bal, method = "naive_bayes")
res_nb <- evaluate_model(model_nb, test_data, "Naive Bayes")

#  5. Comparaison des résultats
results <- rbind(res_log, res_tree, res_rf, res_nb)
cat("\n\n--- Résultats des modèles ---\n")
print(results)

# Normalisation des variables numériques
numeric_vars <- c("age", "avg_glucose_level", "bmi")
stroke_data[numeric_vars] <- scale(stroke_data[numeric_vars])
# Séparation des données en train/test
set.seed(123)
index <- createDataPartition(stroke_data$stroke, p = 0.7, list = FALSE)
train_data <- stroke_data[index, ]
test_data  <- stroke_data[-index, ]

# --------------------------
# 🧠 Fonction d’évaluation
# --------------------------
evaluate_model <- function(pred, true, model_name) {
  cm <- confusionMatrix(as.factor(pred), as.factor(true), positive = "Stroke")
  auc_val <- auc(roc(as.numeric(true), as.numeric(pred == "Stroke")))
  f1 <- F1_Score(y_pred = pred, y_true = true, positive = "Stroke")
  
  cat("\n---", model_name, "---\n")
  print(cm)
  cat("AUC:", auc_val, "\n")
  cat("F1 Score:", f1, "\n")
  
  return(data.frame(
    Model = model_name,
    Accuracy = cm$overall["Accuracy"],
    Sensitivity = cm$byClass["Sensitivity"],
    Specificity = cm$byClass["Specificity"],
    F1 = f1,
    AUC = auc_val
  ))
}
# --------------------------
# Entraînement des modèles
# --------------------------

results <- list()

## 1. Naive Bayes
model_nb <- naiveBayes(stroke ~ ., data = train_data)
pred_nb <- predict(model_nb, newdata = test_data)
results[[4]] <- evaluate_model(pred_nb, test_data$stroke, "Naive Bayes")

## 2. XGBoost
library(xgboost)
train_matrix <- model.matrix(stroke ~ . -1, data = train_data)
train_label <- as.numeric(train_data$stroke) - 1
test_matrix <- model.matrix(stroke ~ . -1, data = test_data)
test_label <- test_data$stroke
xgb_model <- xgboost(
  data = train_matrix,
  label = train_label,
  objective = "binary:logistic",
  eval_metric = "auc",
  scale_pos_weight = sum(train_label == 0) / sum(train_label == 1),
  nrounds = 100,
  verbose = 0
)
pred_xgb_prob <- predict(xgb_model, test_matrix)
pred_xgb <- ifelse(pred_xgb_prob > 0.3, "Stroke", "No Stroke")
results[[5]] <- evaluate_model(pred_xgb, test_label, "XGBoost")

results_df <- do.call(rbind, results)
print(results_df)

# -----------------------------------

# Cost Sensitive Learning

set.seed(123)
index <- createDataPartition(stroke_data$stroke, p = 0.8, list = FALSE)
train_data <- stroke_data[index, ]
test_data  <- stroke_data[-index, ]

# define cost matrix strategy

cost_matrix <- matrix(c(0, 1,   # FP (No Stroke → Stroke) = 1
                        10, 0), # FN (Stroke → No Stroke) = 10 (high penalty)
                      nrow = 2, byrow = TRUE)
colnames(cost_matrix) <- rownames(cost_matrix) <- c("No Stroke", "Stroke")

# class weights for glm or random forest

# give 10x more importance to "Stroke"
train_data$weights <- ifelse(train_data$stroke == "Stroke", 10, 1)

# Logistic Regression with cost-sensitive learning
model_log <- train(
  x = subset(train_data, select = -c(stroke, weights)),
  y = train_data$stroke,
  method = "glm", family = "binomial",
  weights = train_data$weights
)
# Evaluate the model
eval_log <- evaluate_model(predict(model_log, newdata = test_data), test_data$stroke, "Logistic Regression (Cost-Sensitive)")


#     SMOTE        #
# Install if needed
packages <- c("caret", "DMwR", "ROSE", "randomForest", "pROC", "MLmetrics", "rpart")
installed <- packages %in% rownames(installed.packages())
if (any(!installed)) install.packages(packages[!installed])
library(caret)
library(DMwR)
library(ROSE)
library(randomForest)
library(pROC)
library(MLmetrics)
library(rpart)


evaluate_model <- function(model, test_data, model_name) {
  pred <- predict(model, newdata = test_data)
  cm <- confusionMatrix(pred, test_data$stroke)
  auc_val <- auc(roc(as.numeric(test_data$stroke), as.numeric(pred)))
  f1 <- F1_Score(pred, test_data$stroke, positive = "Stroke")
  
  return(data.frame(
    Model = model_name,
    Accuracy = cm$overall["Accuracy"],
    Sensitivity = cm$byClass["Sensitivity"],
    Specificity = cm$byClass["Specificity"],
    F1 = f1,
    AUC = auc_val
  ))
}

run_imbalance_experiment <- function(train_data, test_data) {
  results <- list()
  
  ## 1. Baseline
  model_baseline <- train(stroke ~ ., data = train_data, method = "rf", ntree = 100)
  results[[1]] <- evaluate_model(model_baseline, test_data, "Random Forest (Original)")
  
  ## 3. SMOTE
  train_data$stroke <- as.factor(train_data$stroke)  # Ensure factor
  smote_data <- SMOTE(stroke ~ ., data = train_data, perc.over = 300, perc.under = 150)
  model_smote <- train(stroke ~ ., data = smote_data, method = "rf", ntree = 100)
  results[[3]] <- evaluate_model(model_smote, test_data, "Random Forest (SMOTE)")
  
  ## 4. Downsampling
  down <- downSample(x = train_data[, -which(names(train_data) == "stroke")],
                     y = train_data$stroke)
  colnames(down)[ncol(down)] <- "stroke"
  model_down <- train(stroke ~ ., data = down, method = "rf", ntree = 100)
  results[[4]] <- evaluate_model(model_down, test_data, "Random Forest (Downsample)")
  
  ## 5. Cost-sensitive
  model_cost <- randomForest(stroke ~ ., data = train_data,
                             ntree = 100, classwt = c("No Stroke" = 1, "Stroke" = 10))
  results[[5]] <- evaluate_model(model_cost, test_data, "Random Forest (Cost-Sensitive)")
  
  # Return as one data frame
  do.call(rbind, results)
}


# Split your dataset
set.seed(123)
index <- createDataPartition(stroke_data$stroke, p = 0.8, list = FALSE)
train_data <- stroke_data[index, ]
test_data <- stroke_data[-index, ]

# Run all techniques
results <- run_imbalance_experiment(train_data, test_data)


print(results)

# matrice de confusion pour le modèle Random Forest avec SMOTE
png("oneFileCode/figures/confusion_matrix_rf_smote.png", width = 800, height = 600)
confusion_matrix_rf_smote <- confusionMatrix(predict(model_smote, newdata = test_data), test_data$stroke)
fourfoldplot(confusion_matrix_rf_smote$table, color = c("#56B4E9", "#D55E00"), 
             conf.level = 0, margin = 1, main = "Matrice de confusion - Random Forest (SMOTE)")
dev.off()


# -----------------------------------
# 💾 Sauvegarde du modèle
# -----------------------------------
if (!dir.exists("models")) dir.create("models")
install.packages("plumber")
library(plumber)
saveRDS(model_log, "models/stroke_model_log.rds")



















