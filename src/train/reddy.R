# This scripts trains models specified in below src/models on the Reddy 
# training data

library(patroklos)

data <- readRDS("data/reddy/data.rds")
data$cohort <- "train"

source("src/models/reddy.R")
# models <- basic

training_camp(models, data, skip_on_error = TRUE, update_model_shell = FALSE)