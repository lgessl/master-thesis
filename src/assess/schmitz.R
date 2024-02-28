# Assess the models trained on Schmitz training data on the Schmitz test data

library(lymphomaSurvivalPipeline)

source("src/train/models.R") # basic_models, ei_models
source("src/assess/ass.R") # ass2d_list, auc_ass_scalar


basic_models <- prepend_to_directory(basic_models, "models/schmitz")
ei_models <- prepend_to_directory(ei_models, "models/schmitz")

data <- readRDS("data/schmitz/data.rds")
data$cohort <- "test"

for(ass2d in ass2d_list)
    ass2d$assess_center(data, basic_models)

auc_ass_scalar$file <- "models/schmitz/auc.csv"
auc_ass_scalar$assess_center(data, basic_models)

auc_ass_scalar$file <- "models/schmitz/ei_auc.csv"
auc_ass_scalar$assess_center(data, ei_models)
