# predict_stroke.R

library(jsonlite)
library(caret)
library(nnet)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) stop("Pas de données en entrée")

# Lire les données JSON passées depuis Laravel
input <- fromJSON(args[1])

# Charger le modèle entraîné
model <- readRDS("nn_model.rds")

# Charger les paramètres de normalisation
norm <- readRDS("norm_params.rds")

# Fonction de normalisation
normalize <- function(x, min, max) (x - min) / (max - min)

# Appliquer la normalisation
input$age_norm <- normalize(input$age, norm$age_min, norm$age_max)
input$bmi_norm <- normalize(input$bmi, norm$bmi_min, norm$bmi_max)
input$glucose_norm <- normalize(input$glucose, norm$glucose_min, norm$glucose_max)

# Transformation des variables en facteurs avec bons niveaux
input <- data.frame(
  gender = factor(input$gender, levels = c("Male", "Female", "Other")),
  hypertension = factor(input$hypertension, levels = c("No", "Yes")),
  heart_disease = factor(input$heart_disease, levels = c("No", "Yes")),
  ever_married = factor(input$ever_married, levels = c("No", "Yes")),
  work_type = factor(input$work_type, levels = c("Private", "Self-employed", "Govt_job", "children", "Never_worked")),
  Residence_type = factor(input$Residence_type, levels = c("Urban", "Rural")),
  smoking_status = factor(input$smoking_status, levels = c("formerly smoked", "never smoked", "smokes", "Unknown")),
  age_norm = input$age_norm,
  bmi_norm = input$bmi_norm,
  glucose_norm = input$glucose_norm
)

# Garder les colonnes nécessaires
input <- input[, c("gender", "age_norm", "hypertension", "heart_disease", "ever_married",
                   "work_type", "Residence_type", "glucose_norm", "bmi_norm", "smoking_status")]

# Prédire les probabilités
result <- predict(model, input, type = "prob")

# Afficher la prédiction en JSON
cat(toJSON(result))
