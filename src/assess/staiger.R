# Assess the models trained on the Staiger training data 
# - on the Staiger training data according to their validated predictions 
#   (-> results/staiger/val.csv), 
# - pick the best model with minimal validation error and 
# - assess it on the Staiger test data (-> results/staiger/test.csv)

library(patroklos)

source("src/assess/ass.R") # For pan_ass_scalar
data <- readRDS("data/staiger/data.rds")
source("src/models/staiger.R")

data$cohort <- "val_predict"
pan_ass_scalar$file <- "results/staiger/val.csv"
val_tbl <- pan_ass_scalar$assess_center(data, models)

data$cohort <- "test"
pan_ass_scalar$file <- "results/staiger/test.csv"
# The first three models are tied, choose simplest one among them
models <- models[val_tbl[["model"]][3]] 
pan_ass_scalar$assess_center(data, models)