# This scripts trains all models specified in model_spec.R on the Schmitz training data

library(lymphomaSurvivalPipeline)

source("src/train/models.R") # model_spec_list

data <- readRDS("data/schmitz/data.rds")

basic_models <- prepend_to_directory(basic_models, "models/schmitz")
ei_models <- prepend_to_directory(ei_models, "models/schmitz")

training_camp(basic_models, data)
training_camp(ei_models, data)