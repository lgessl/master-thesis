# Assess models on combined big data set

library(patroklos)

source("src/assess/ass.R")

data <- readRDS("data/all/data.rds")
data$cohort <- "schmitz"

source("src/models/all.R")

prepend_to_directory(models, "models/all")
prepend_to_filename(ass_scalar_list, "results/all")

pan_ass_scalar$assess_center(data, models)