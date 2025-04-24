# -----------------------------------
# 📦 Load Libraries (Install if Needed)
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
# 📁 Create folder for figures
# -----------------------------------
if (!dir.exists("figures")) dir.create("figures")

# -----------------------------------

# -----------------------------------
# 📂 Load Data
# -----------------------------------
file_path <- "datasets/healthcare-dataset-stroke-data.csv"
stroke_data <- read_csv(file_path)

# -----------------------------------

# Save row count before cleaning
rows_before <- nrow(stroke_data)
print(paste("Rows before cleaning:", rows_before))
# -----------------------------------

# 👁️ Glimpse and Drop Useless Columns
# -----------------------------------
glimpse(stroke_data)
stroke_data <- stroke_data %>% select(-id)

# -----------------------------------
# Convert character columns to factors
stroke_data <- stroke_data %>% mutate_if(is.character, as.factor)

# Convert BMI from character to numeric (handles "N/A" as NA)
stroke_data$bmi <- as.numeric(as.character(stroke_data$bmi))

# Convert stroke to factor
stroke_data$stroke <- as.factor(stroke_data$stroke)
# -----------------------------------
# 📊 Visualize Variable Lengths and Highlight Missing
# -----------------------------------

# Count non-NA values per column
non_na_counts <- stroke_data %>%
  summarise(across(everything(), ~ sum(!is.na(.)))) %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "non_na_count")

# Total row count (max possible per variable)
total_rows <- nrow(stroke_data)

# Add a column to flag if there's missing data
non_na_counts <- non_na_counts %>%
  mutate(has_na = if_else(non_na_count < total_rows, TRUE, FALSE))

# Plot with colors for missing
png("figures/variable_lengths_highlight_missing.png", width = 1000, height = 600)
ggplot(non_na_counts, aes(x = reorder(variable, -non_na_count), y = non_na_count, fill = has_na)) +
  geom_bar(stat = "identity", width = 0.7) +
  scale_fill_manual(values = c("FALSE" = "gray40", "TRUE" = "#FF4B7D")) +
  labs(title = "Length of Each Variable (Before Cleaning)",
       subtitle = paste0("Total rows: ", total_rows, " — Variables with missing values in red"),
       x = "Variable",
       y = "Non-missing Count",
       fill = "Missing?") +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()
# -----------------------------------

# -----------------------------------
# 🧼 Clean Data (Drop Missing and Duplicates)
# -----------------------------------
stroke_data_clean <- stroke_data %>% drop_na()
duplicates <- stroke_data_clean[duplicated(stroke_data_clean), ]
n_duplicates <- nrow(duplicates)
stroke_data_clean <- stroke_data_clean %>% distinct()

rows_after <- nrow(stroke_data_clean)

# -----------------------------------

# print nb of rows before and after cleaning
cat("🧾 Rows before cleaning:", rows_before, "\n")
cat("🧾 Rows after cleaning :", rows_after, "\n")
cat("❌ Duplicates removed  :", n_duplicates, "\n")

# -----------------------------------
# 🔍 Missing Value Summary (After Cleaning)
# -----------------------------------
missing_values_clean <- colSums(is.na(stroke_data_clean))
print(missing_values_clean)

# -----------------------------------

# 📸 Save Missing Values Plot (After)
png("figures/missing_values_after_cleaning.png", width = 1000, height = 600)
gg_miss_var(stroke_data_clean) +
  labs(title = "Missing Values After Cleaning",
       subtitle = paste0("Total rows: ", rows_after, " — No missing values"),
       x = "Variable",
       y = "Missing Count") +
  theme_minimal(base_size = 14)
dev.off()







