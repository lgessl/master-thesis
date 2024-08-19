# Assess the models trained on the Reddy training data 
# - on the Reddy training data according to their validated predictions (-> results/reddy/val.csv), 
# - pick the best model with minimal validation error and 
# - assess it on the Reddy test data (-> results/reddy/test.csv)

library(patroklos)

source("src/assess/ass.R") # For pan_ass_scalar
data <- readRDS("data/reddy/data.rds")
source("src/models/reddy.R")

data$cohort <- "val_predict"
pan_ass_scalar$file <-  "results/reddy/val.csv"
eval_tbl <- pan_ass_scalar$assess_center(data, models)

data$cohort <- "test"
pan_ass_scalar$file <- "results/reddy/test.csv"
models <- models[eval_tbl[["model"]][1]] # Pick
pan_ass_scalar$assess_center(data, models)