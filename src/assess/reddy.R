# Assess the models trained on Reddy et al.

library(patroklos)

source("src/assess/ass.R") # ass2d_list
data <- readRDS("data/reddy/data.rds")
source("src/models/reddy.R")
# models <- basic
prepend_to_directory(models, "models/reddy")

# Select best model based on validated predictions
data$cohort <- "val_predict"
pan_ass_scalar$file <-  "results/reddy/panta_val.csv"
eval_tbl <- pan_ass_scalar$assess_center(data, models)

# Assess it on the test data
data$cohort <- "test"
pan_ass_scalar$file <- "results/reddy/panta_test.csv"
# models <- models[eval_tbl[["model"]][1]]
pan_ass_scalar$assess_center(data, models)