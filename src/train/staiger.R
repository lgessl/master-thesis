# This script trains the models specified in src/models/staiger on the Staiger training data

library(patroklos)

data <- readRDS("data/staiger/data.rds")
data$cohort <- "train"
source("src/models/staiger.R")

training_camp(models, data, skip_on_error = FALSE, update_model_shell = FALSE)