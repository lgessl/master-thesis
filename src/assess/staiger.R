# Assess the models trained on staiger 

library(patroklos)

error_discrepancy <- T
source("src/assess/ass.R") # ass2d_list
data <- readRDS("data/staiger/data.rds")
source("src/models/staiger.R")

data$cohort <- "val_predict"
pan_ass_scalar$file <- "results/staiger/panta_val.csv"
val_tbl <- pan_ass_scalar$assess_center(data, models)

data$cohort <- "test"
pan_ass_scalar$file <- "results/staiger/panta_test.csv"
models <- models[val_tbl[["model"]][1:3]]
pan_ass_scalar$assess_center(data, models)

# val_vs_test(
#     model_list = models,
#     data = data,
#     error_fun = neg_prec_with_prev_greater(0.17),
#     spotlight_regex = "^cox-cox|cox-log",
#     file = "results/staiger/meta_gauss-glm.jpeg",
#     spotlight_name = "cox-[glm]",
#     plot_theme = plot_themes[["thesis"]],
#     colors = colors
# )
# val_vs_test(
#     model_list = models,
#     data = data,
#     error_fun = neg_prec_with_prev_greater(0.17),
#     spotlight_regex = "cox-rf",
#     file = "results/staiger/meta_cox-rf.jpeg",
#     spotlight_name = "cox-rf",
#     plot_theme = plot_themes[["thesis"]]
# )
# val_vs_test(
#     model_list = models,
#     data = data,
#     error_fun = neg_prec_with_prev_greater(0.17),
#     spotlight_regex = "no expr",
#     file = "results/staiger/meta_no_expr.jpeg",
#     spotlight_name = "no RNA-seq",
#     plot_theme = plot_themes[["thesis"]]
# )