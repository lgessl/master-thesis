# Assess the models trained on Schmitz

library(patroklos)

source("src/assess/ass.R") # ass2d_list
data <- readRDS("data/schmitz/data.rds")
source("src/models/schmitz.R")
# models <- basic
prepend_to_directory(models, "models/schmitz")

data$cohort <- "val_predict"
pan_ass_scalar$file <- "results/schmitz/panta_val.csv"
eval_tbl <- pan_ass_scalar$assess_center(data, models)

data$cohort <- "test"
pan_ass_scalar$file <- "results/schmitz/panta_test.csv"
# models <- models[eval_tbl[["model"]][1]]
pan_ass_scalar$assess_center(data, models)
