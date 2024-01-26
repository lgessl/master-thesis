# This scripts trains all models specified in model_spec.R on the Schmitz training data

library(lymphomaSurvivalPipeline)

source("src/train/model_spec.R") # model_spec_list

data_spec <- readRDS("data/schmitz/data_spec.rds")

model_spec_list <- prepend_to_directory(model_spec_list, "models/schmitz")

training_camp(
    data_spec = data_spec,
    model_spec_list = prepend_to_directory(list(cox_vanilla_std), "models/schmitz")
)

training_camp(
    data_spec = data_spec,
    model_spec_list = model_spec_list
)