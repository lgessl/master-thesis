# This scripts trains models specified below src/models on the Schmitz 
# training data

library(patroklos)

data <- readRDS("data/schmitz/data.rds")
data$cohort <- "train"

source("src/models/schmitz.R")

prepend_to_directory(models, "models/schmitz") 
training_camp(models, data, skip_on_error = FALSE)
