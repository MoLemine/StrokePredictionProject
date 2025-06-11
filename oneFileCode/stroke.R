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

# -----------------------------------
       # end nettoyage space
# -----------------------------------

# -------------------------------------------

    # 📊 Visualisation des données (eda)

# ------------------------------------------




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

#-------------Cost-Sensitive Learning--------------------#

# séparer les jeux d'entraînement/test

library(caret)
set.seed(123)
train_index <- createDataPartition(stroke_data$stroke, p = 0.8, list = FALSE)
train_data <- stroke_data[train_index, ]
test_data <- stroke_data[-train_index, ]

# Application du Cost-Sensitive Learning
cost_matrix <- matrix(c(0, 1, 5, 0), nrow = 2,
                      dimnames = list(predicted = c("No Stroke", "Stroke"),
                                      actual = c("No Stroke", "Stroke")))


# Logistic Regression avec pondération
model_log_cs <- train(stroke ~ ., data = train_data,
                      method = "glm",
                      family = "binomial",
                      weights = ifelse(train_data$stroke == "Stroke", 5, 1))

# Random Forest avec pondération
library(randomForest)
model_rf <- randomForest(stroke ~ ., data = train_data,
                         classwt = c("No Stroke" = 1, "Stroke" = 5))
# KNN avec cost-sensitive
model_knn <- train(stroke ~ ., data = train_data,
                      method = "knn",
                      tuneGrid = expand.grid(k = 5),
                      weights = ifelse(train_data$stroke == "Stroke", 5, 1))


# Evaluation des modèles (Logistic Regression, Random Forest, KNN) 
# evaluation function
evaluate_model_cs <- function(model, test_data, model_name) {
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
# Evaluation des modèles
results_log_cs <- evaluate_model_cs(model_log_cs, test_data, "Régression Logistique (Cost-Sensitive)")
results_rf_cs <- evaluate_model_cs(model_rf, test_data, "Random Forest (Cost-Sensitive)")
results_knn_cs <- evaluate_model_cs(model_knn, test_data, "KNN (Cost-Sensitive)")
# Comparaison des résultats
results_comparison <- data.frame(
  Model = c("Logistic Regression", "Random Forest", "KNN"),
  Accuracy = c(results_log_cs$Accuracy, results_rf_cs$Accuracy, results_knn_cs$Accuracy),
  Sensitivity = c(results_log_cs$Sensitivity, results_rf_cs$Sensitivity, results_knn_cs$Sensitivity),
  Specificity = c(results_log_cs$Specificity, results_rf_cs$Specificity, results_knn_cs$Specificity),
  F1 = c(results_log_cs$F1, results_rf_cs$F1, results_knn_cs$F1),
  AUC = c(results_log_cs$AUC, results_rf_cs$AUC, results_knn_cs$AUC)
)
# Affichage des résultats
print(results_comparison)
# Visualisation des résultats comparison
# save the figure
png("oneFileCode/figures/comparison_models_cost_sensitive.png", width = 1200, height = 800)
results_long <- results_comparison %>%
  pivot_longer(cols = -Model, names_to = "Metric", values_to = "Value")
ggplot(results_long, aes(x = Model, y = Value, fill = Metric)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Comparaison des modèles (Cost-Sensitive Learning)",
       x = "Modèle", y = "Valeur") +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold"),
    legend.title = element_text(size = 13),
    legend.text = element_text(size = 12)
  )
dev.off()
# visualisation des résultats de matrice de confusion 
# logistic regression
png("oneFileCode/figures/confusion_matrix_logistic.png", width = 800, height = 600)
cm_log <- confusionMatrix(predict(model_log_cs, test_data), test_data$stroke)
ggplot(as.data.frame(cm_log$table), aes(x = Reference, y = Prediction, fill = Freq)) +
  geom_tile(color = "white") +
  geom_text(aes(label = Freq), color = "black", size = 5) +
  scale_fill_gradient(low = "lightblue", high = "darkblue") +
  labs(title = "Matrice de confusion - Régression Logistique (Cost-Sensitive)",
       x = "Classe réelle", y = "Classe prédite") +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold")
  )
dev.off()
# random forest
png("oneFileCode/figures/confusion_matrix_rf.png", width = 800, height = 600)
cm_rf <- confusionMatrix(predict(model_rf, test_data), test_data$stroke)
ggplot(as.data.frame(cm_rf$table), aes(x = Reference, y = Prediction, fill = Freq)) +
  geom_tile(color = "white") +
  geom_text(aes(label = Freq), color = "black", size = 5) +
  scale_fill_gradient(low = "lightblue", high = "darkblue") +
  labs(title = "Matrice de confusion - Random Forest (Cost-Sensitive)",
       x = "Classe réelle", y = "Classe prédite") +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold")
  )
dev.off()
# KNN
png("oneFileCode/figures/confusion_matrix_knn.png", width = 800, height = 600)
cm_knn <- confusionMatrix(predict(model_knn, test_data), test_data$stroke)
ggplot(as.data.frame(cm_knn$table), aes(x = Reference, y = Prediction, fill = Freq)) +
  geom_tile(color = "white") +
  geom_text(aes(label = Freq), color = "black", size = 5) +
  scale_fill_gradient(low = "lightblue", high = "darkblue") +
  labs(title = "Matrice de confusion - KNN (Cost-Sensitive)",
       x = "Classe réelle", y = "Classe prédite") +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold")
  )
dev.off()


# Features importance for logistic regression
variable_importance_log <- varImp(model_log_cs, scale = FALSE)
# visualisation des features importance
png("oneFileCode/figures/variable_importance_logistic.png", width = 1200, height = 800)
ggplot(variable_importance_log, aes(x = reorder(Variable, Overall), y = Overall)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Importance des variables - Régression Logistique (Cost-Sensitive)",
       x = "Variables", y = "Importance") +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold")
  )
dev.off()


# features importance for random forest
variable_importance_rf <- varImp(model_rf, scale = FALSE)


# hyperparams vesion ----------------#
# Transform categorical variables into factors with explicit levels
stroke_data_clean <- stroke_data_clean %>%
  mutate(
    gender = factor(gender),
    ever_married = factor(ever_married),
    work_type = factor(work_type),
    Residence_type = factor(Residence_type),
    smoking_status = factor(smoking_status),
    hypertension = factor(hypertension, levels = c(0, 1), labels = c("No", "Yes")),
    heart_disease = factor(heart_disease, levels = c(0, 1), labels = c("No", "Yes")),
    stroke = factor(stroke, levels = c(0, 1), labels = c("NoStroke", "Stroke")) # Use valid R variable names
  )
# Normalize continuous variables
preprocess_params <- preProcess(stroke_data_clean %>% select(age, avg_glucose_level, bmi),
                                method = c("center", "scale"))
stroke_data_normalized <- predict(preprocess_params, stroke_data_clean)
# Split data into training (80%) and testing (20%) sets
trainIndex <- createDataPartition(stroke_data_normalized$stroke, p = 0.8, list = FALSE)
train_data <- stroke_data_normalized[trainIndex, ]
test_data <- stroke_data_normalized[-trainIndex, ]

# Define class weights for cost-sensitive learning
# Higher weight for minority class (Stroke)
class_weights <- ifelse(train_data$stroke == "Stroke", 10, 1)
# Define training control with cross-validation
ctrl <- trainControl(
  method = "cv",
  number = 5,
  summaryFunction = twoClassSummary, # ROC-AUC
  classProbs = TRUE, #  probability scores
  verboseIter = TRUE
)
#  Logistic Regression with Cost-Sensitive Learning
logistic_model <- train(
  stroke ~ .,
  data = train_data,
  method = "glm",
  family = "binomial",
  weights = class_weights,
  trControl = ctrl,
  metric = "ROC"
)
#  Random Forest with Cost-Sensitive Learning
rf_model <- train(
  stroke ~ .,
  data = train_data,
  method = "rf",
  weights = class_weights,
  trControl = ctrl,
  metric = "ROC",
  tuneGrid = expand.grid(mtry = c(2, 4, 6)) # Tune mtry
)
#  KNN with Cost-Sensitive Learning
knn_model <- train(
  stroke ~ .,
  data = train_data,
  method = "knn",
  weights = class_weights,
  trControl = ctrl,
  metric = "ROC",
  tuneGrid = expand.grid(k = c(3, 5, 7, 9)) # Tune k
)
# Evaluate models on test data
models <- list(Logistic = logistic_model, RandomForest = rf_model, KNN = knn_model)
results <- lapply(models, function(model) {
  predictions <- predict(model, test_data)
  cm <- confusionMatrix(predictions, test_data$stroke, positive = "Stroke")
  roc_auc <- roc(test_data$stroke, predict(model, test_data, type = "prob")[, "Stroke"])$auc
  list(
    ConfusionMatrix = cm,
    ROC_AUC = roc_auc
  )
})
# Print results
for (model_name in names(results)) {
  cat("\nResults for", model_name, ":\n")
  print(results[[model_name]]$ConfusionMatrix)
  cat("ROC-AUC:", results[[model_name]]$ROC_AUC, "\n")
}


# Probabilité # de Stroke avec glmnet
library(glmnet)

x <- model.matrix(stroke ~ ., train_data)[, -1]
y <- train_data$stroke

model_glmnet <- cv.glmnet(x, y, family = "binomial", alpha = 0.5,
                          weights = class_weights,
                          type.measure = "auc")

# Prédiction
x_test <- model.matrix(stroke ~ ., test_data)[, -1]
probs_glmnet <- predict(model_glmnet, newx = x_test, s = "lambda.min", type = "response")
pred_glmnet <- ifelse(probs_glmnet > 0.3, "Stroke", "NoStroke")

confusionMatrix(factor(pred_glmnet, levels = c("NoStroke", "Stroke")),
                test_data$stroke, positive = "Stroke")

# visualisation de matrice confusion
png("oneFileCode/figures/confusion_matrice_glmnet.png", width = 800, height = 600)
cm_glmnet <- confusionMatrix(factor(pred_glmnet, levels = c("NoStroke", "Stroke")),
                              test_data$stroke, positive = "Stroke")
ggplot(as.data.frame(cm_glmnet$table), aes(x = Reference, y = Prediction, fill = Freq)) +
  geom_tile(color = "white", linewidth = 1) +
  geom_text(aes(label = Freq), color = "black", size = 6, fontface = "bold") +
  scale_fill_gradient(low = "#c6dbef", high = "#08306b") +  # palette bleu lisible
  labs(title = "Matrice de confusion - GLMNET",
       x = "Classe réelle", y = "Classe prédite") +
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 16, face = "bold"),
    axis.title.y = element_text(size = 16, face = "bold"),
    axis.text = element_text(size = 14),
    legend.position = "none",               # Supprime la légende inutile
    panel.grid = element_blank()
  )

dev.off()

#--------- arbre de décision avec discrétisation ------------#


# Discretize numerical variables into 10 equal-width intervals
stroke_data_discretized <- stroke_data_clean %>%
  mutate(
    age = cut(age, breaks = 10, include.lowest = TRUE, dig.lab = 3),
    avg_glucose_level = cut(avg_glucose_level, breaks = 10, include.lowest = TRUE, dig.lab = 3),
    bmi = cut(bmi, breaks = 10, include.lowest = TRUE, dig.lab = 3)
  )

# Split data into training (80%) and testing (20%) sets
trainIndex <- createDataPartition(stroke_data_discretized$stroke, p = 0.8, list = FALSE)
train_data <- stroke_data_discretized[trainIndex, ]
test_data <- stroke_data_discretized[-trainIndex, ]

# Define class weights for cost-sensitive learning
# Higher weight for minority class (Stroke)
class_weights <- ifelse(train_data$stroke == "Stroke", 10, 1)

# Define training control with cross-validation
ctrl <- trainControl(
  method = "cv",
  number = 5,
  summaryFunction = twoClassSummary, # For ROC-AUC
  classProbs = TRUE, # For probability scores
  verboseIter = TRUE
)
# Train Decision Tree with Cost-Sensitive Learning
dt_model <- train(
  stroke ~ .,
  data = train_data,
  method = "rpart",
  weights = class_weights,
  trControl = ctrl,
  metric = "ROC",
  tuneGrid = expand.grid(cp = seq(0.01, 0.1, by = 0.01)) # Tune complexity parameter
)
# Evaluate model on test data
predictions <- predict(dt_model, test_data)
cm <- confusionMatrix(predictions, test_data$stroke, positive = "Stroke")
roc_auc <- roc(test_data$stroke, predict(dt_model, test_data, type = "prob")[, "Stroke"])$auc
# Visualize the decision tree
rpart.plot(dt_model$finalModel, main = "Decision Tree for Stroke Prediction", extra = 104, under = TRUE)
