# Assess the models trained on Schmitz training data on the Schmitz test data

library(patroklos)

source("src/assess/ass.R") # ass2d_list

data <- readRDS("data/schmitz/data.rds")
data$cohort <- "test"

source("src/models/schmitz.R")

prepend_to_directory(models, "models/schmitz")
prepend_to_filename(ass_scalar_list, "results/schmitz")
# 2D
for(ass2d in ass2d_list[NULL])
    ass2d$assess_center(data, models)
# Scalar
pan_ass_scalar$assess_center(data, models)