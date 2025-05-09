

# -----------------------------------
      # Memoire projet version
# -----------------------------------

# 📦 Chargement et installation des bibliothèques nécessaires
packages <- c("tidyverse", "ggplot2", "GGally", "corrplot","ggcorrplot","DMwR",
              "caret","smotefamily","knitr","unbalanced")
installed <- packages %in% rownames(installed.packages())
if (any(!installed)) {
  install.packages(packages[!installed])
}

# 📚 Importation des bibliothèques
library(tidyverse)
library(ggplot2)
library(GGally)
library(corrplot)
library(dplyr)
library(gridExtra)
library(ggcorrplot)
 

library(caret)
library(smotefamily)

# 📂 Chargement des données nettoyées depuis un fichier .rds
stroke_data_clean <- readRDS("datasets/stroke_data_clean.rds")


# Visualisation de variable cible (stroke) et save png 
# create folder figures/eda if not exists
if (!dir.exists("figures/eda")) dir.create("figures/eda")
png("figures/eda/distribution_stroke.png", width = 1000, height = 600)
ggplot(stroke_data_clean, aes(x = factor(stroke))) +
  geom_bar(fill = "#0072B2") +
  labs(x = "Stroke (0 = Non, 1 = Oui)", y = "Nombre de patients") +
  ggtitle("Distribution de la variable cible (Stroke)") +
  theme_minimal()

dev.off()

# visualisation des variables continues


# 📊 Sélectionner les variables continues
numeric_vars <- stroke_data_clean %>% select_if(is.numeric)

# 📐 Transformer au format long pour ggplot
long_numeric <- numeric_vars %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "value")

# 📸 Sauvegarder l'image avec plusieurs sous-graphiques (facets)
png("figures/eda/distribution_vars_continu.png", width = 1200, height = 800)

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
# age vs bmi 
png("figures/eda/age_vs_bmi.png", width = 1200, height = 800)
ggplot(stroke_data_clean, aes(x = age, y = bmi)) +
  geom_point(aes(color = factor(stroke)), alpha = 0.5) +
  labs(title = "Relation entre l'âge et le BMI selon la présence d'un AVC",
       x = "Âge", y = "BMI", color = "AVC") +
  scale_color_manual(values = c("#0072B2", "#FF0000"),
                     labels = c("Non AVC", "AVC")) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.position = "top",
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 11)
  )

# age vs bmi (stroke oui ou non )







# 📊 Analyse univariée des variables catégorielles
# Sélectionner les variables catégorielles
cat_vars <- stroke_data_clean %>% select_if(is.factor)

# chaque deux variables catégorielles dans un png
for (var in names(cat_vars)) {
  p <- ggplot(stroke_data_clean, aes_string(x = var)) +
    geom_bar(fill = "#0072B2") +
    labs(title = paste("Distribution de", var), x = var, y = "Nombre") +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, size = 8, color = "black"), # texte noir
      axis.text.y = element_text(color = "black"), # texte des axes y aussi noir
      axis.title.x = element_text(color = "black"),
      axis.title.y = element_text(color = "black"),
      plot.title = element_text(size = 10, color = "black") # titre en noir aussi
    )
  
  # créer le dossier figures/eda s'il n'existe pas
  if (!dir.exists("figures/eda")) dir.create("figures/eda")
  
  # sauvegarder le png
  ggsave(filename = paste0("figures/eda/univar_catg_", var, ".png"), plot = p, width = 8, height = 5)
}

# analyse bivariée entre chaque variable  et la variable cible (stroke)

# creer le dossier figures/eda/bivariee s'il n'existe pas
if (!dir.exists("figures/eda/bivariee")) dir.create("figures/eda/bivariee")
# aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
# Distribution âge vs AVC
png("figures/eda/bivariee/age_vs_stroke.png", width = 1200, height = 800)

# Créer des intervalles d'âge (30 intervalles)
stroke_data_clean <- stroke_data_clean %>%
  mutate(age_bin = cut(age, breaks = 30))

# Résumer les données par tranche d'âge
age_summary <- stroke_data_clean %>%
  group_by(age_bin) %>%
  summarise(
    total = n(),
    stroke_cases = sum(stroke == 1)
  ) %>%
  mutate(mid_point = (as.numeric(sub("\\((.+),.*", "\\1", age_bin)) + 
                        as.numeric(sub(".*,(.+)\\]", "\\1", age_bin))) / 2)

# Tracer l'histogramme
ggplot(stroke_data_clean, aes(x = age, fill = factor(stroke))) +
  geom_histogram(bins = 15, position = "stack", color = "white") +
  geom_text(data = age_summary, aes(x = mid_point, y = total, label = stroke_cases),
            inherit.aes = FALSE, vjust = -0.5, size = 3, color = "red", fontface = "bold") +
  labs(
    title = "Distribution de l'âge selon la présence d'un AVC",
    x = "Âge",
    y = "Nombre de patients",
    fill = ""
  ) +
  scale_fill_manual(
    values = c("#0072B2", "#FF0000"),
    labels = c("Non AVC", "AVC")
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.position = "top",
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 11)
  )

dev.off()

# Hypertension vs AVC
png("figures/eda/bivariee/hypertension_vs_stroke.png", width = 1200, height = 800)

ggplot(stroke_data_clean, aes(x = factor(hypertension), fill = factor(stroke))) +
  geom_bar(position = "dodge", color = "white") +  # Ajout du contour pour l'esthétique
  labs(
    title = "Répartition selon l'hypertension et l'AVC",
    x = "Hypertension (0 = Non, 1 = Oui)",
    y = "Nombre de patients",
    fill = ""
  ) +
  scale_fill_manual(
    values = c("#0072B2", "#FF0000"),
    labels = c("Non AVC", "AVC")
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.position = "top",
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 11)
  )

dev.off()

# Statut tabagique vs AVC
png("figures/eda/bivariee/smoking_status_vs_stroke.png", width = 1200, height = 800)

ggplot(stroke_data_clean, aes(x = smoking_status, fill = factor(stroke))) +
  geom_bar(position = "dodge", color = "white") +  # Ajout du contour
  labs(
    title = "Répartition selon le statut tabagique et l'AVC",
    x = "Statut tabagique",
    y = "Nombre de patients",
    fill = ""
  ) +
  scale_fill_manual(
    values = c("#0072B2", "#FF0000"),
    labels = c("Non AVC", "AVC")
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.position = "top",
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 11)
  )

dev.off()

# bmi vs AVC
png("figures/eda/bivariee/bmi_vs_stroke.png", width = 1200, height = 800)

ggplot(stroke_data_clean, aes(x = bmi, fill = factor(stroke))) +
  geom_histogram(binwidth = 2, position = "stack", color = "white") +
  labs(
    title = "Distribution du BMI selon la présence d'un AVC",
    x = "BMI",
    y = "Nombre de patients",
    fill = ""
  ) +
  scale_fill_manual(
    values = c("#0072B2", "#FF0000"),
    labels = c("Non AVC", "AVC")
  ) +
  scale_x_continuous(limits = c(10, 60)) +  # <-- ajout ici pour limiter l'axe X
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.position = "top",
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 11)
  )
dev.off()
# Residance_type vs AVC
png("figures/eda/bivariee/residence_type_vs_stroke.png", width = 1200, height = 800)
ggplot(stroke_data_clean, aes(x = Residence_type, fill = factor(stroke))) +
  geom_bar(position = "dodge", color = "white") +  # Ajout du contour
  labs(
    title = "Répartition selon le type de résidence et l'AVC",
    x = "Type de résidence",
    y = "Nombre de patients",
    fill = ""
  ) +
  scale_fill_manual(
    values = c("#0072B2", "#FF0000"),
    labels = c("Non AVC", "AVC")
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.position = "top",
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 11)
  )
dev.off()

# work type vs AVC
png("figures/eda/bivariee/work_type_vs_stroke.png", width = 1200, height = 800)
ggplot(stroke_data_clean, aes(x = work_type, fill = factor(stroke))) +
  geom_bar(position = "dodge", color = "white") +  # Ajout du contour
  labs(
    title = "Répartition selon le type de travail et l'AVC",
    x = "Type de travail",
    y = "Nombre de patients",
    fill = ""
  ) +
  scale_fill_manual(
    values = c("#0072B2", "#FF0000"),
    labels = c("Non AVC", "AVC")
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.position = "top",
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 11)
  )
dev.off()


# matriel status vs AVC
# Sauvegarde du graphique
png("figures/eda/bivariee/marital_status_vs_stroke.png", width = 1200, height = 800)

# Création du graphique
ggplot(stroke_data_clean, aes(x = ever_married, fill = factor(stroke))) +
  geom_bar(position = "dodge", color = "white") +  # Barres côte à côte avec contour blanc
  labs(
    title = "Répartition selon le statut marital et l'AVC",
    x = "Statut marital (Marié ou non)",
    y = "Nombre de patients",
    fill = "Présence d'AVC"
  ) +
  scale_x_discrete(labels = c("No" = "Non marié", "Yes" = "Marié")) +  # Traduire Yes/No
  scale_fill_manual(
    values = c("#0072B2", "#FF0000"),
    labels = c("Non AVC", "AVC")
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.position = "top",
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 11)
  )

dev.off()

# heart_disease vs AVC
png("figures/eda/bivariee/heart_disease_vs_stroke.png", width = 1200, height = 800)
ggplot(stroke_data_clean, aes(x = factor(heart_disease), fill = factor(stroke))) +
  geom_bar(position = "dodge", color = "white") +  # Ajout du contour
  labs(
    title = "Répartition selon la maladie cardiaque et l'AVC",
    x = "Maladie cardiaque (0 = Non, 1 = Oui)",
    y = "Nombre de patients",
    fill = ""
  ) +
  scale_fill_manual(
    values = c("#0072B2", "#FF0000"),
    labels = c("Non AVC", "AVC")
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.position = "top",
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 11)
  )
dev.off()
# avg_glucose_level vs AVC
png("figures/eda/bivariee/avg_glucose_level_vs_stroke.png", width = 1200, height = 800)
ggplot(stroke_data_clean, aes(x = avg_glucose_level, fill = factor(stroke))) +
  geom_histogram(binwidth = 5, position = "stack", color = "white") +
  labs(
    title = "Distribution du taux moyen de glucose selon la présence d'un AVC",
    x = "Taux moyen de glucose",
    y = "Nombre de patients",
    fill = ""
  ) +
  scale_fill_manual(
    values = c("#0072B2", "#FF0000"),
    labels = c("Non AVC", "AVC")
  ) +
  coord_cartesian(xlim = c(30, 300)) +  # <-- Remplacer scale_x_continuous par coord_cartesian
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.position = "top",
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 11)
  )

dev.off()

# bmi vs AVC
png("figures/eda/bivariee/bmi_vs_stroke.png", width = 1200, height = 800)

ggplot(stroke_data_clean, aes(x = bmi, fill = factor(stroke))) +
  geom_histogram(binwidth = 2, position = "stack", color = "white") +
  labs(
    title = "Distribution du BMI selon la présence d'un AVC",
    x = "BMI",
    y = "Nombre de patients",
    fill = ""
  ) +
  scale_fill_manual(
    values = c("#0072B2", "#FF0000"),
    labels = c("Non AVC", "AVC")
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.position = "top",
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 11)
  )

dev.off()

# gender vs AVC

png("figures/eda/bivariee/gender_vs_stroke.png", width = 1200, height = 800)

# Création du graphique
ggplot(stroke_data_clean, aes(x = gender, fill = factor(stroke))) +
  geom_bar(position = "stack", color = "white") +
  labs(
    title = "Répartition selon le genre et la présence d'un AVC",
    x = "Genre",
    y = "Nombre de patients",
    fill = ""
  ) +
  scale_fill_manual(
    values = c("#0072B2", "#FF0000"),
    labels = c("Non AVC", "AVC")
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.position = "top",
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 11)
  )

# Fermeture du fichier png
dev.off()

# matrice de corrélation entre les variables continues
# Créer le dossier figures/eda/correlation s'il n'existe pas

if (!dir.exists("figures/eda/correlation")) dir.create("figures/eda/correlation")


stroke_data_clean <- stroke_data_clean %>%
  mutate(stroke = as.numeric(as.character(stroke)))
# Sélectionner les variables continues
numeric_vars <- stroke_data_clean %>%
  select(where(is.numeric))

# Calcul de la matrice de corrélation
cor_matrix <- cor(numeric_vars, use = "complete.obs", method = "pearson")

# Sauvegarder la matrice de corrélation
png("figures/eda/correlation/correlation_matrix.png", width = 1200, height = 800)

ggcorrplot(cor_matrix, 
           method = "square", 
           type = "upper", 
           lab = TRUE, 
           lab_size = 3, 
           colors = c("#6D9EC1", "white", "#E46726"),
           title = "Matrice de Corrélation des Variables Numériques",
           ggtheme = ggplot2::theme_minimal())

dev.off()

# Sauvegarder la matrice de corrélation sous forme de tableau
png("figures/eda/correlation/correlation_table.png", width = 1200, height = 800)
corrplot(cor_matrix, 
         method = "color", 
         type = "upper", 
         addCoef.col = "black",
         tl.cex = 0.8, 
         number.cex = 0.7, 
         title = "Matrice de Corrélation des Variables Numériques",
         mar = c(0,0,1,0))
dev.off()

# running smote function on stroke_data_clean
predictor_variables <- stroke_data_clean %>% select(-stroke)
response_variable <- stroke_data_clean$stroke

# running smote function on data
Smote_data <- ubBalance(predictor_variables, 
                        response_variable, 
                        type='ubSMOTE',     # Option for SMOTE
                        perc.over = 100,    # Percentage of oversampling
                        perc.under = 200,   # Percentage of undersampling
                        k = 5,              # Number of nearest neighbors
                      
                        verbose = TRUE      # Verbose output
                        )

















# -----------------------------------
        # End memoire projet version
# -----------------------------------

# -----------------------------------
        # Github Copilot version
# -----------------------------------

# 
# 
# # -----------------------------------
# # 📁 eda.R - Analyse exploratoire des données (EDA)
# # -----------------------------------
# 
# # 📦 Chargement et installation des bibliothèques nécessaires
# packages <- c("tidyverse", "ggplot2", "GGally", "corrplot")
# installed <- packages %in% rownames(installed.packages())
# if (any(!installed)) {
#   install.packages(packages[!installed])
# }
# 
# # 📚 Importation des bibliothèques
# library(tidyverse)
# library(ggplot2)
# library(GGally)
# library(corrplot)
# library(dplyr)
# library(gridExtra)
# 
# # 📂 Chargement des données nettoyées depuis un fichier .rds
# stroke_data_clean <- readRDS("datasets/stroke_data_clean.rds")
# 
# # 📁 Création du dossier figures pour stocker les graphiques
# if (!dir.exists("figures")) dir.create("figures")
# 
# # 📊 Analyse statistique des variables continues
# 
# # Sélection des variables continues
# num_cont <- stroke_data_clean %>% select(age, avg_glucose_level, bmi)
# 
# # Calcul des statistiques descriptives
# summary_stats <- data.frame(
#   Variable = c("age", "avg_glucose_level", "bmi"),
#   Moyenne = sapply(num_cont, mean),
#   Médiane = sapply(num_cont, median),
#   `Écart-type` = sapply(num_cont, sd),
#   Min = sapply(num_cont, min),
#   Max = sapply(num_cont, max)
# )
# 
# # Arrondir les valeurs pour faciliter la lecture
# summary_stats <- summary_stats %>%
#   mutate(across(where(is.numeric), ~ round(., 2)))
# 
# # 📸 Export du tableau des statistiques sous forme d'image
# png("figures/statistiques_numeriques.png", width = 1000, height = 600)
# gridExtra::grid.table(summary_stats)
# dev.off()
# 
# # 📊 Analyse des variables catégorielles
# 
# # Sélection des variables de type facteur
# cat_vars <- stroke_data_clean %>% select_if(is.factor)
# 
# # Création d'une liste vide pour stocker les graphiques
# plots_list <- list()
# 
# # Boucle pour générer un graphique par variable catégorielle
# for (var in names(cat_vars)) {
#   p <- ggplot(stroke_data_clean, aes(x = .data[[var]])) +
#     geom_bar(fill = "#FFA07A") +
#     labs(title = paste("Distribution de", var), x = var, y = "Nombre") +
#     theme_minimal() +
#     theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
#           plot.title = element_text(size = 10))
#   plots_list[[var]] <- p
# }
# 
# # 📤 Export de la grille de graphiques des variables catégorielles
# png("figures/frequences_variables_categorielles.png", width = 1200, height = 800)
# gridExtra::grid.arrange(grobs = plots_list, ncol = 2)
# dev.off()
# 
# # 📊 Distribution de la variable cible : stroke
# png("figures/distribution_stroke.png", width = 800, height = 500)
# ggplot(stroke_data_clean, aes(x = stroke)) +
#   geom_bar(fill = "steelblue") +
#   labs(title = "Distribution de la variable cible : AVC",
#        x = "AVC (0 = Non, 1 = Oui)", y = "Nombre de cas") +
#   theme_minimal()
# dev.off()
# 
# # 📈 Analyse univariée des variables continues
# 
# # Sélection des variables numériques
# numeric_vars <- stroke_data_clean %>% select_if(is.numeric)
# 
# # Mise en forme longue pour facettage
# long_numeric <- numeric_vars %>%
#   pivot_longer(cols = everything(), names_to = "variable", values_to = "value")
# 
# # Histogrammes pour chaque variable continue
# png("figures/analyse_univariee_continues.png", width = 1000, height = 600)
# ggplot(long_numeric, aes(x = value)) +
#   geom_histogram(bins = 30, fill = "skyblue", color = "white") +
#   facet_wrap(~ variable, scales = "free") +
#   labs(title = "Distribution des variables continues") +
#   theme_minimal()
# dev.off()
# 
# # 🔁 Histogrammes et boxplots côte à côte pour chaque variable continue
# for (var in names(numeric_vars)) {
#   
#   p_hist <- ggplot(stroke_data_clean, aes(x = .data[[var]])) +
#     geom_histogram(bins = 30, fill = "skyblue", color = "white") +
#     labs(title = paste("Distribution de la variable", var), x = var, y = "Fréquence") +
#     theme_minimal()
#   
#   p_box <- ggplot(stroke_data_clean, aes(y = .data[[var]])) +
#     geom_boxplot(fill = "orange", color = "black") +
#     coord_flip() +
#     labs(title = paste("Boxplot de", var), y = var, x = "") +
#     theme_minimal()
#   
#   # Création du dossier "images" si nécessaire
#   if (!dir.exists("images")) dir.create("images")
#   
#   # 📤 Sauvegarde des graphiques en image
#   png(filename = paste0("images/distribution_", var, ".png"), width = 1000, height = 400)
#   gridExtra::grid.arrange(p_hist, p_box, ncol = 2)
#   dev.off()
# }
# 
# # 📊 Analyse univariée des variables catégorielles
# cat_vars <- stroke_data_clean %>% select_if(is.factor)
# 
# # Génération et sauvegarde de barplots pour chaque variable catégorielle
# for (var in names(cat_vars)) {
#   p <- ggplot(stroke_data_clean, aes_string(x = var)) +
#     geom_bar(fill = "lightgreen") +
#     labs(title = paste("Distribution de", var), x = var, y = "Nombre") +
#     theme_minimal()
#   ggsave(filename = paste0("figures/univar_cat_", var, ".png"), plot = p, width = 8, height = 5)
# }
# 
# # 🔁 Analyse bivariée entre variables continues
# num_cont <- stroke_data_clean %>% select(age, avg_glucose_level, bmi)
# 
# # Matrice de paires pour visualiser les relations entre variables continues
# png("figures/analyse_bivariee_continues.png", width = 800, height = 800)
# GGally::ggpairs(num_cont)
# dev.off()
# 
# # 🔗 Corrélation entre les variables numériques
# cor_matrix <- cor(num_cont)
# png("figures/correlation_matrix.png", width = 800, height = 700)
# corrplot(cor_matrix, method = "color", type = "upper", addCoef.col = "black",
#          tl.cex = 0.8, number.cex = 0.7, title = "Corrélation entre les variables continues", mar = c(0,0,1,0))
# dev.off()
# 
# # 📊 Analyse bivariée : AVC vs variables continues (boxplots)
# for (var in names(num_cont)) {
#   p <- ggplot(stroke_data_clean, aes_string(x = var, y = "stroke", fill = "factor(stroke)")) +
#     geom_boxplot() +
#     labs(title = paste("Boxplot de", var, "selon AVC"),
#          x = var, y = "AVC (0 = Non, 1 = Oui)") +
#     theme_minimal()
#   
#   ggsave(filename = paste0("figures/bivariee_cont_stroke_", var, ".png"), plot = p, width = 7, height = 5)
# }
# 
# # 📊 Analyse bivariée : AVC vs variables catégorielles (proportions empilées)
# cat_vars_biv <- stroke_data_clean %>% select_if(is.factor) %>% select(-stroke)
# 
# for (var in names(cat_vars_biv)) {
#   plot_data <- stroke_data_clean %>%
#     group_by(across(all_of(var)), stroke) %>%
#     summarise(n = n(), .groups = "drop") %>%
#     group_by(across(all_of(var))) %>%
#     mutate(percentage = n / sum(n)) %>%
#     ungroup()
#   
#   p <- ggplot(plot_data, aes_string(x = var, y = "percentage", fill = "factor(stroke)")) +
#     geom_bar(stat = "identity", position = "stack", width = 0.6) +
#     scale_y_continuous(labels = scales::percent_format()) +
#     scale_fill_manual(values = c("0" = "#6A0DAD", "1" = "#FF4C61"),
#                       name = "Stroke", labels = c("No Stroke", "Stroke")) +
#     labs(title = paste("Proportion d'AVC selon", var),
#          x = var, y = "Proportion") +
#     theme_minimal() +
#     theme(plot.title = element_text(size = 14, face = "bold"))
#   
#   ggsave(filename = paste0("figures/bivariee_cat_stroke_", var, ".png"), plot = p, width = 7, height = 5)
# }
# 
# # 🔁 Deuxième version : Répartition des AVC en barplot empilé
# cat_vars <- stroke_data_clean %>%
#   select_if(is.factor) %>%
#   select(-stroke) # exclusion de la variable cible
# 
# for (var in names(cat_vars)) {
#   p <- ggplot(stroke_data_clean, aes_string(x = var, fill = "stroke")) +
#     geom_bar(position = "fill") +
#     scale_fill_manual(values = c("0" = "lightblue", "1" = "tomato"),
#                       labels = c("0" = "Pas d'AVC", "1" = "AVC")) +
#     labs(title = paste("Répartition des AVC selon", var),
#          x = var, y = "Proportion", fill = "AVC") +
#     theme_minimal()
#   
#   ggsave(filename = paste0("images/stroke_vs_", var, ".png"),
#          plot = p, width = 8, height = 5)
# }

# -----------------------------------------------------------
                  # end github copilot version #

# -----------------------------------------------------------

# 
# #-----------------------------------------------------------
#                   # chatGPT version #
# #-----------------------------------------------------------
# 
# # eda_visualisations.R
# 
# # Packages
# library(ggplot2)
# library(corrplot)
# library(dplyr)
# 
# # Charger les données
# # Remplacer "path_to_data" par le chemin correct vers votre fichier CSV
# data <- read.csv("datasets/healthcare-dataset-stroke-data.csv")
# 
# # -------------------
# # Partie 1 : Visualisation de la variable cible
# # -------------------
# ggplot(data, aes(x = factor(stroke))) +
#   geom_bar(fill = "#0072B2") +
#   labs(x = "Stroke (0 = Non, 1 = Oui)", y = "Nombre de patients") +
#   ggtitle("Distribution de la variable cible (Stroke)") +
#   theme_minimal()
# ggsave("figures/distribution_stroke.png", width = 8, height = 6)
# 
# # -------------------
# # Partie 2 : Analyse univariée
# # -------------------
# 
# # Variables continues
# # Age
# ggplot(data, aes(x = age)) +
#   geom_histogram(bins = 30, fill = "#56B4E9", color = "black") +
#   labs(title = "Distribution de l'âge", x = "Âge", y = "Fréquence") +
#   theme_minimal()
# ggsave("figures/distribution_age.png", width = 8, height = 6)
# 
# # Taux de glucose moyen
# ggplot(data, aes(x = avg_glucose_level)) +
#   geom_histogram(bins = 30, fill = "#E69F00", color = "black") +
#   labs(title = "Distribution du taux moyen de glucose", x = "Taux de glucose moyen", y = "Fréquence") +
#   theme_minimal()
# ggsave("figures/distribution_avg_glucose.png", width = 8, height = 6)
# 
# # BMI
# ggplot(data, aes(x = bmi)) +
#   geom_histogram(bins = 30, fill = "#009E73", color = "black") +
#   labs(title = "Distribution de l'indice de masse corporelle (BMI)", x = "BMI", y = "Fréquence") +
#   theme_minimal()
# ggsave("figures/distribution_bmi.png", width = 8, height = 6)
# 
# # Variables catégorielles
# # Genre
# ggplot(data, aes(x = gender, fill = factor(stroke))) +
#   geom_bar(position = "dodge") +
#   labs(title = "Répartition selon le sexe et l'AVC", x = "Genre", y = "Nombre") +
#   scale_fill_manual(values = c("#56B4E9", "#D55E00"), labels = c("Non AVC", "AVC")) +
#   theme_minimal()
# ggsave("figures/stroke_vs_gender.png", width = 8, height = 6)
# 
# # Statut tabagique
# ggplot(data, aes(x = smoking_status, fill = factor(stroke))) +
#   geom_bar(position = "dodge") +
#   labs(title = "Répartition selon le statut tabagique et l'AVC", x = "Statut tabagique", y = "Nombre") +
#   scale_fill_manual(values = c("#56B4E9", "#D55E00"), labels = c("Non AVC", "AVC")) +
#   theme_minimal()
# ggsave("figures/stroke_vs_smoking_status.png", width = 8, height = 6)
# 
# # -------------------
# # Partie 3 : Analyse bivariée
# # -------------------
# 
# # Boxplot Âge vs Stroke
# ggplot(data, aes(x = factor(stroke), y = age, fill = factor(stroke))) +
#   geom_boxplot() +
#   labs(title = "Distribution de l'âge selon la présence d'un AVC", x = "Stroke (0 = Non, 1 = Oui)", y = "Âge") +
#   scale_fill_manual(values = c("#56B4E9", "#D55E00")) +
#   theme_minimal()
# ggsave("figures/boxplot_age_stroke.png", width = 8, height = 6)
# 
# # Hypertension vs Stroke
# ggplot(data, aes(x = factor(hypertension), fill = factor(stroke))) +
#   geom_bar(position = "dodge") +
#   labs(title = "Lien entre hypertension et AVC", x = "Hypertension (0 = Non, 1 = Oui)", y = "Nombre de patients") +
#   scale_fill_manual(values = c("#56B4E9", "#D55E00")) +
#   theme_minimal()
# ggsave("figures/stroke_vs_hypertension.png", width = 8, height = 6)
# 
# # -------------------
# # Partie 4 : Corrélation entre variables
# # -------------------
# 
# # Matrice de corrélation
# vars_continues <- data[, c("age", "avg_glucose_level", "bmi")]
# cor_matrix <- cor(vars_continues, use = "complete.obs")
# 
# # Sauvegarder la matrice (facultatif)
# write.csv(cor_matrix, "figures/matrice_correlation.csv")
# 
# # Heatmap corrélation
# png("figures/heatmap_correlation.png", width = 800, height = 600)
# corrplot(cor_matrix, method = "color", type = "upper", tl.col = "black", addCoef.col = "black")
# dev.off()
# 
# # ------------------------------------------------------
#                # end chatGPT version
# # ------------------------------------------------------
