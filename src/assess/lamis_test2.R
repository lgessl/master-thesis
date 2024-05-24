# Assess the models trained on lamis_test2 training data on the lamis_test2 test data

library(patroklos)

source("src/assess/ass.R") # ass2d_list

data <- readRDS("data/lamis_test2/data.rds")
data$cohort <- "test"

model_groups <- c("li", "basic", "ei")

all_models <- list()
for (mg in model_groups) {
    source(paste0("src/models/", mg, ".R"))
    all_models <- c(all_models, the_best)
}
prepend_to_directory(all_models, "models/lamis_test2")
prepend_to_filename(ass_scalar_list, "models/lamis_test2")
# 2D
# for(ass2d in ass2d_list)
    # ass2d$assess_center(data, models)
# Scalar
pan_ass_scalar$assess_center(data, all_models)