
# Load required libraries
library(tidyverse)
library(caret)
library(nnet)

# Load and preprocess the dataset with continuous variables
file_path <- "datasets/healthcare-dataset-stroke-data.csv"
set.seed(123)  # For reproducibility
stroke_data <- read_csv(file_path) %>%
  select(-id) %>%
  mutate(across(where(is.character), as.factor),
         bmi = as.numeric(as.character(bmi)),
         stroke = as.factor(stroke)) %>%
  drop_na() %>%
  distinct() %>%
  mutate(
    gender = factor(gender),
    ever_married = factor(ever_married),
    work_type = factor(work_type),
    Residence_type = factor(Residence_type),
    smoking_status = factor(smoking_status),
    hypertension = factor(hypertension, levels = c(0, 1), labels = c("No", "Yes")),
    heart_disease = factor(heart_disease, levels = c(0, 1), labels = c("No", "Yes")),
    stroke = factor(stroke, levels = c(0, 1), labels = c("NoStroke", "Stroke"))
  )

# Split data into training (80%) and test (20%) sets
trainIndex <- createDataPartition(stroke_data$stroke, p = 0.8, list = FALSE)
train_data <- stroke_data[trainIndex, ]
test_data <- stroke_data[-trainIndex, ]

# Extract raw values before normalization
age_raw <- train_data$age
bmi_raw <- train_data$bmi
glucose_raw <- train_data$avg_glucose_level

# Save normalization parameters properly
norm_params <- list(
  age_min = min(age_raw),
  age_max = max(age_raw),
  bmi_min = min(bmi_raw),
  bmi_max = max(bmi_raw),
  glucose_min = min(glucose_raw),
  glucose_max = max(glucose_raw)
)
saveRDS(norm_params, "C:/Users/MoLemine/Documents/StrokePrediction/norm_params.rds")

# Normalize continuous variables to [0, 1]
normalize <- function(x, min_val, max_val) {
  (x - min_val) / (max_val - min_val)
}

stroke_data <- stroke_data %>%
  mutate(
    age_norm = normalize(age, norm_params$age_min, norm_params$age_max),
    bmi_norm = normalize(bmi, norm_params$bmi_min, norm_params$bmi_max),
    glucose_norm = normalize(avg_glucose_level, norm_params$glucose_min, norm_params$glucose_max)
  ) %>%
  select(-age, -bmi, -avg_glucose_level)

# Recreate train/test split after normalization
train_data <- stroke_data[trainIndex, ]
test_data <- stroke_data[-trainIndex, ]

# Calculate class weights for cost-sensitive learning
class_counts <- table(train_data$stroke)
total_samples <- sum(class_counts)
base_weights <- (total_samples / class_counts) / sum(total_samples / class_counts)
weight_multiplier <- 1.5
class_weights <- base_weights * weight_multiplier
names(class_weights) <- levels(train_data$stroke)

# Define training control for cross-validation
train_control <- trainControl(method = "cv", number = 5,
                              classProbs = TRUE, summaryFunction = twoClassSummary)

# Define tuning grid for neural network parameters
tune_grid <- expand.grid(size = c(5, 10, 15, 20),
                         decay = c(0.001, 0.01, 0.1, 0.15))

# Train neural network with cost-sensitive learning
nn_model <- train(stroke ~ ., data = train_data,
                  method = "nnet",
                  trControl = train_control,
                  tuneGrid = tune_grid,
                  metric = "ROC",
                  maxit = 500,
                  trace = FALSE,
                  weights = class_weights[train_data$stroke])

# Save model
saveRDS(nn_model, "C:/Users/MoLemine/Documents/StrokePrediction/nn_model.rds")

# Print summary
print(nn_model)
