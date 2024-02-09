# Assess the models trained on Schmitz training data on the Schmitz test data

library(lymphomaSurvivalPipeline)

source("src/train/model_spec.R") # model_spec_list
source("src/assess/ass_spec.R") # as2_list, auc_as0

as2_list <- as2_list

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
as2_fnames_infix <- c(
    "cox/0-vanilla/zerosum",
    "cox/0-vanilla/std",
    "cox/0-vanilla/glmnet",
    "cox/1-zerosum",
    "logistic/0-vanilla/zerosum",
    "logistic/0-vanilla/std",
    "logistic/0-vanilla/glmnet",
    "logistic/1-zerosum"
)

data_spec <- readRDS("data/schmitz/data_spec.rds")

for(as2 in as2_list){
    top_fname <- as2$fname
    for(i in c(2, 3, 6, 7)){ # seq_along(msl_name)){
        as2$fname <- file.path("models/schmitz", as2_fnames_infix[i], top_fname)
        msl_sub <- model_spec_list[msl_name[[i]]]
        assess_2d_center(
            model_spec_list = msl_sub,
            data_spec = data_spec,
            perf_plot_spec = as2,
            cohorts = c("train", "test")
        )
    }
}

auc_as0$file <- "models/schmitz/auc.csv"
assess_0d_center(
    ass_spec_0d = auc_as0,
    data_spec = data_spec,
    model_spec_list = model_spec_list
)