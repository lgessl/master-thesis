# Assess the models trained on Schmitz

library(patroklos)

source("src/assess/ass.R") # ass2d_list
data <- readRDS("data/schmitz/data.rds")
source("src/models/schmitz.R")

data$cohort <- "val_predict"
pan_ass_scalar$file <- "results/schmitz/panta_val.csv"
eval_tbl <- pan_ass_scalar$assess_center(data, models)

data$cohort <- "test"
pan_ass_scalar$file <- "results/schmitz/panta_test.csv"
models <- models[eval_tbl[["model"]][1]]
pan_ass_scalar$assess_center(data, models)

# val_vs_test(
#     model_list = models,
#     data = data,
#     error_fun = neg_prec_with_prev_greater(0.17),
#     spotlight_regex = c("gauss-cox|gauss-gauss", "ridge", "std", "gauss-rf", "rf"),
#     file = "results/schmitz/meta_gauss-glm.jpeg",
#     spotlight_name = c("gauss-[glm]", "ridge", "std", "gauss-rf", "rf core"),
#     plot_theme = plot_themes[["thesis"]]
# )