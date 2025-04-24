# Check structure
str(stroke_data)

# Summary statistics
summary(stroke_data)

# Check for missing values
colSums(is.na(stroke_data))

# Remove rows with missing values
stroke_data_clean <- stroke_data %>% drop_na()
#  Convert character columns to factors
stroke_data_clean <- stroke_data_clean %>%
  mutate_if(is.character, as.factor)
#  Handle specific column, e.g., bmi might have missing values
stroke_data_clean$bmi <- as.numeric(stroke_data_clean$bmi)
stroke_data_clean <- stroke_data_clean %>% drop_na(bmi)
is.numeric(stroke_data_clean$bmi)
# Check for duplicates
stroke_data_clean[duplicated(stroke_data_clean), ]
# Remove duplicates
# stroke_data_clean <- stroke_data_clean %>% distinct() there are no duplicates

# Check class distribution
class_distribution <- table(stroke_data_clean$stroke)
# Visualize class distribution 0 not stroke, 1 stroke
library(ggplot2)
ggplot(data = as.data.frame(class_distribution), aes(x = Var1, y = Freq)) +
  geom_bar(stat = "identity") +
  labs(title = "Distribution des classes d'AVC ", x = "AVC (0 = pas d'AVC, 1 = AVC)", y = "Fréquence" ) +
  theme_minimal()
# Or a prettier version percentage :
stroke_data_clean %>%
  count(stroke) %>%
  mutate(percent = n / sum(n) * 100)




