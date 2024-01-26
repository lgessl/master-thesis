# Assess the models trained on Schmitz training data on the Schmitz test data

library(lymphomaSurvivalPipeline)

source("src/train/model_spec.R") # model_spec_list
source("src/assess/perf_plot_spec.R") # pps_list

pps_list <- pps_list

model_spec_list <- prepend_to_directory(model_spec_list, "models/schmitz")
msl_name <- list(
    "cox_vanilla_zerosum",
    "cox_vanilla_std",
    "cox_vanilla_glmnet",
    "cox_zerosum",
    "logistic_vanilla_zerosum",
    "logistic_vanilla_std",
    "logistic_vanilla_glmnet",
    "logistic_zerosum"
)
pps_fnames_infix <- c(
    "cox/0-vanilla/zerosum",
    "cox/0-vanilla/glmnet",
    "cox/0-vanilla/std",
    "cox/1-zerosum",
    "logistic/0-vanilla/zerosum",
    "logistic/0-vanilla/std",
    "logistic/0-vanilla/glmnet",
    "logistic/1-zerosum"
)

data_spec <- readRDS("data/schmitz/data_spec.rds")

for(pps in pps_list){
    top_fname <- pps$fname
    for(i in c(2, 6)){ # seq_along(msl_name)){
        pps$fname <- file.path("models/schmitz", pps_fnames_infix[i], top_fname)
        msl_sub <- model_spec_list[msl_name[[i]]]
        assessment_center(
            model_spec_list = msl_sub,
            data_spec = data_spec,
            perf_plot_spec = pps,
            cohorts = c("train", "test")
        )
    }
}