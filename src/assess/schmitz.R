# Assess the models trained on Schmitz training data on the Schmitz test data

library(lymphomaSurvivalPipeline)

source("src/train/model_spec.R") # basic_models
source("src/assess/ass_spec.R") # ass2d_list, auc_as0


basic_models <- prepend_to_directory(basic_models, "models/schmitz")
ei_models <- prepend_to_directory(ei_models, "models/schmitz")

data <- readRDS("data/schmitz/data.rds")
data$cohort <- "test"

for(ass2d in ass2d_list)
    ass2d$assess_center(data, basic_models)

auc_as0$file <- "models/schmitz/auc.csv"
auc_ass_scalar$assess_center(data, basic_models)

auc_as0$file <- "models/schmitz/ei_auc.csv"
auc_ass_scalar$assess_center(data, basic_models)