# Assess the models trained on the Schmitz training data 
# - on the Schmitz training data according to their validated predictions 
#   (-> results/schmitz/val.csv), 
# - pick the best model with minimal validation error and 
# - assess it on the Schmitz test data (-> results/schmitz/test.csv)

library(patroklos)

source("src/assess/config.R") # For pan_ass_scalar
data <- readRDS("data/schmitz/data.rds")
source("src/models/schmitz.R")

data$cohort <- "val_predict"
pan_ass_scalar$file <- "results/schmitz/val.csv"
eval_tbl <- pan_ass_scalar$assess_center(data, models)

data$cohort <- "test"
pan_ass_scalar$file <- "results/schmitz/test.csv"
models <- models[eval_tbl[["model"]][1]] # Pick
pan_ass_scalar$assess_center(data, models)