# Train models on combined big data set

library(patroklos)

data <- readRDS("data/all/data.rds")
data$cohort <- "lamis"

source("src/models/all.R")

prepend_to_directory(models, "models/all")
training_camp(models, data, skip_on_error = FALSE)
