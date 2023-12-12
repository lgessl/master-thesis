# Assess the models trained on Schmitz training data on the Schmitz test data

library(lymphomaSurvivalPipeline)

source("src/train/model_spec.R") # model_spec_list
source("src/assess/perf_plot_spec.R") # std_pps

model_spec_list <- prepend_to_save_dir(model_spec_list, "models/schmitz")
std_pps$fname <- file.path("models/schmitz", std_pps$fname)

ds_train <- readRDS("data/schmitz/train/data_spec.rds")
ds_test <- readRDS("data/schmitz/test/data_spec.rds")

assess_train_and_test(
    model_spec_list = model_spec_list,
    data_spec_train = ds_train,
    data_spec_test = ds_test,
    perf_plot_spec_train = std_pps
)