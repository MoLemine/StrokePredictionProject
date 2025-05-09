# -----------------------------------
# 📦 Chargement des bibliothèques
# -----------------------------------
packages <- c("tidyverse", "naniar", "DataExplorer", "ggplot2","rlang","GGally","corrplot","dplyr")
installed <- packages %in% rownames(installed.packages())
if (any(!installed)) {
  install.packages(packages[!installed])
}
library(dplyr)
library(tidyverse)
library(naniar)
library(ggplot2)
library(DataExplorer)
library(GGally)   # pour ggpairs
library(corrplot) # pour matrice de corrélation



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









































