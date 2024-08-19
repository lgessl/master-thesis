# This scripts trains models specified in src/models/schmitz.R on the Schmitz training data

library(patroklos)

data <- readRDS("data/schmitz/data.rds")
data$cohort <- "train"
source("src/models/schmitz.R")

training_camp(models, data, skip_on_error = FALSE, update_model_shell = FALSE)