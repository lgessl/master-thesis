# Assess the models trained on Schmitz training data on the Schmitz test data

library(lymphomaSurvivalPipeline)

source("src/train/model_spec.R") # basic_msl
source("src/assess/ass_spec.R") # as2_list, auc_as0


basic_msl <- prepend_to_directory(basic_msl, "models/schmitz")
ei_msl <- prepend_to_directory(ei_msl, "models/schmitz")

data_spec <- readRDS("data/schmitz/data_spec.rds")

for(as2 in as2_list){
    assess_2d_center(
        ass_spec_2d = as2,
        model_spec_list = c(basic_msl, ei_msl),
        data_spec = data_spec,
        cohorts = c("train", "test"),
        comparison_plot = FALSE
    )
}

auc_as0$file <- "models/schmitz/auc.csv"
assess_0d_center(
    ass_spec_0d = auc_as0,
    data_spec = data_spec,
    model_spec_list = basic_msl,
    cohorts = c("test")
)

auc_as0$file <- "models/schmitz/ei_auc.csv"
assess_0d_center(
    ass_spec_0d = auc_as0,
    data_spec = data_spec,
    model_spec_list = ei_msl,
    cohorts = c("test")
)
