# install packages if not already installed
if (!requireNamespace("tidyverse", quietly = TRUE)) {
  install.packages("tidyverse")
}

# Load required libraries

library(tidyverse)

# Set your file path (adjust if needed)
file_path <- "datasets/healthcare-dataset-stroke-data.csv"

# Load the data
stroke_data <- read_csv(file_path)

# View the first few rows
head(stroke_data)
