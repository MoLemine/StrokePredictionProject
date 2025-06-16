
args <- commandArgs(trailingOnly = TRUE)

# Charger les bibliothèques nécessaires
library(tidyverse)
library(ggplot2)
library(lattice)
library(caret)
library(nnet)

# Charger le modèle et les paramètres de normalisation
model <- readRDS("C:/Users/MoLemine/Documents/StrokePrediction/nn_model.rds")
norm_params <- readRDS("C:/Users/MoLemine/Documents/StrokePrediction/norm_params.rds")

# Lire les arguments
gender <- args[1]
hypertension <- args[2]
heart_disease <- args[3]
ever_married <- args[4]
work_type <- args[5]
Residence_type <- args[6]
smoking_status <- args[7]
age <- as.numeric(args[8])
bmi <- as.numeric(args[9])
glucose <- as.numeric(args[10])

# Appliquer la normalisation
age_norm <- (age - norm_params$age_min) / (norm_params$age_max - norm_params$age_min)
bmi_norm <- (bmi - norm_params$bmi_min) / (norm_params$bmi_max - norm_params$bmi_min)
glucose_norm <- (glucose - norm_params$glucose_min) / (norm_params$glucose_max - norm_params$glucose_min)

# Construire l'entrée du modèle avec les bons types
input_data <- data.frame(
  gender = factor(gender, levels = c("Male", "Female", "Other")),
  hypertension = factor(hypertension, levels = c("No", "Yes")),
  heart_disease = factor(heart_disease, levels = c("No", "Yes")),
  ever_married = factor(ever_married, levels = c("No", "Yes")),
  work_type = factor(work_type, levels = c("Private", "Self-employed", "Govt_job", "Children", "Never_worked")),
  Residence_type = factor(Residence_type, levels = c("Urban", "Rural")),
  smoking_status = factor(smoking_status, levels = c("never smoked", "formerly smoked", "smokes", "Unknown")),
  age_norm = age_norm,
  bmi_norm = bmi_norm,
  glucose_norm = glucose_norm
)

# Faire la prédiction
result <- predict(model, input_data)
print(input_data)

#cat("Résultat :", result)
# Afficher les résultats
cat(as.character(result))
