# This script trains models specified in below src/models on the lamis_test2 
# training data

library(patroklos)

data <- readRDS("data/lamis_test2/data.rds")
data$cohort <- "train"

source("src/models/lamis_test2.R")
# models <- basic

prepend_to_directory(models, "models/lamis_test2") 
training_camp(models, data, skip_on_error = TRUE)