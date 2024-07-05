# Assess the models trained on lamis_test2 

library(patroklos)

source("src/assess/ass.R") # ass2d_list
data <- readRDS("data/lamis_test2/data.rds")
source("src/models/lamis_test2.R")
# models <- basic
prepend_to_directory(models, "models/lamis_test2")

data$cohort <- "val_predict"
pan_ass_scalar$file <- "results/lamis_test2/panta_val.csv"
val_tbl <- pan_ass_scalar$assess_center(data, models)

data$cohort <- "test"
pan_ass_scalar$file <- "results/lamis_test2/panta_test.csv"
# models <- models[val_tbl[["model"]][1]]
pan_ass_scalar$assess_center(data, models)