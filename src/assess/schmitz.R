# Assess the models trained on Schmitz training data on the Schmitz test data

library(lymphomaSurvivalPipeline)

source("src/train/model_spec.R") # model_spec_list
source("src/assess/perf_plot_spec.R") # std_pps

model_spec_list <- prepend_to_save_dir(model_spec_list, "models/schmitz")
data_spec <- readRDS("data/schmitz/test/data_spec.rds")

compare_models(
    model_spec_list = model_spec_list,
    data_spec_list = list(data_spec),
    perf_plot_spec = std_pps
)

data_spec <- readRDS("data/schmitz/train/data_spec.rds")

compare_models(
    model_spec_list = model_spec_list,
    data_spec_list = list(data_spec),
    perf_plot_spec = std_pps,
    model_tree_mirror = c("models", "models")
)
