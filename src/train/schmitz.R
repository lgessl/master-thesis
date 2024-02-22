# This scripts trains all models specified in model_spec.R on the Schmitz training data

library(lymphomaSurvivalPipeline)

source("src/train/model_spec.R") # model_spec_list

data_spec <- readRDS("data/schmitz/data_spec.rds")

basic_msl <- prepend_to_directory(basic_msl, "models/schmitz")
ei_msl <- prepend_to_directory(ei_msl, "models/schmitz")

# training_camp(
#     data_spec = data_spec,
#     model_spec_list = basic_msl
# )

training_camp(
    data_spec = data_spec, 
    model_spec_list = ei_msl
)
