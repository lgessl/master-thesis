# This scripts trains models specified below src/models on the Schmitz 
# training data

library(patroklos)

data <- readRDS("data/schmitz/data.rds")
data$cohort <- "train"

source("src/models/schmitz.R")
# models <- basic

training_camp(models, data, skip_on_error = TRUE, update_model_shell = TRUE)
