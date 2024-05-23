# Assess the models trained on Schmitz training data on the Schmitz test data

library(patroklos)

source("src/assess/ass.R") # ass2d_list

data <- readRDS("data/schmitz/data.rds")
data$cohort <- "test"

model_groups <- c("li", "basic", "ei")

all_models <- list()
for (mg in model_groups) {
    source(paste0("src/models/", mg, ".R"))
    all_models <- c(all_models, models)
}
prepend_to_directory(all_models, "models/schmitz")
prepend_to_filename(ass_scalar_list, "models/schmitz")
# 2D
# for(ass2d in ass2d_list)
    # ass2d$assess_center(data, models)
# Scalar
pan_ass_scalar$file <- paste0("models/schmitz/", "pan_acc.csv")
pan_ass_scalar$assess_center(data, all_models)
