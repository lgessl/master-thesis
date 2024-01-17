# Assess the models trained on Schmitz training data on the Schmitz test data

library(lymphomaSurvivalPipeline)

source("src/train/model_spec.R") # model_spec_list
source("src/assess/perf_plot_spec.R") # std_pps

msl_index <- list(1, 2)
pps_fnames <- c(
    "cox/0-vanilla/the_best.pdf",
    "logistic/0-vanilla/the_best.pdf"
)

data_spec <- readRDS("data/schmitz/data_spec.rds")

for(i in seq_along(msl_index)){
    std_pps$fname <- file.path("models/schmitz", pps_fnames[i])
    msl <- model_spec_list[msl_index[[i]]]
    msl <- prepend_to_directory(msl, "models/schmitz")
    assessment_center(
        model_spec_list = msl,
        data_spec = data_spec,
        perf_plot_spec = std_pps
    )
}