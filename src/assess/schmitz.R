# Assess the models trained on Schmitz training data on the Schmitz test data

library(patroklos)

source("src/assess/ass.R") # ass2d_list

data <- readRDS("data/schmitz/data.rds")
data$cohort <- "test"

model_groups <- c("li") # , "basic", "ei")

for (mg in model_groups) {
    source(paste0("src/models/", mg, ".R")) # models 
    models <- prepend_to_directory(models, "models/schmitz")
    # 2D
    # for(ass2d in ass2d_list)
        # ass2d$assess_center(data, models)
    # Scalar
    all_ass_scalar$file <- paste0("models/schmitz/", mg, "_auc.csv")
    all_ass_scalar$assess_center(data, models)
}
