# This scripts trains models specified in src/models/reddy on the Reddy training data

library(patroklos)

data <- readRDS("data/reddy/data.rds")
data$cohort <- "train"
source("src/models/reddy.R")

training_camp(models, data, skip_on_error = FALSE, update_model_shell = FALSE)