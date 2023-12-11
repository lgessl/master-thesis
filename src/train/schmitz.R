# This scripts trains all models specified in model_spec.R on the Schmitz training data

library(lymphomaSurvivalPipeline)

source("src/train/model_spec.R") # model_spec_list

data_spec <- readRDS("data/schmitz/train/data_spec.rds")

model_spec_list <- prepend_to_save_dir(model_spec_list, "models/schmitz")

data <- read(data_spec)
prepare_and_fit(data$expr_mat, data$pheno_tbl, data_spec, model_spec_list)