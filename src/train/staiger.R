# This script trains models specified in below src/models on the staiger 
# training data

library(patroklos)

data <- readRDS("data/staiger/data.rds")
data$cohort <- "train"

source("src/models/staiger.R")
# models <- basic

training_camp(models, data, skip_on_error = TRUE, update_model_shell = FALSE)