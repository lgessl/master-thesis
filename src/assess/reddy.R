# Assess the models trained on Reddy et al.

library(patroklos)

source("src/assess/ass.R") # ass2d_list
data <- readRDS("data/reddy/data.rds")
source("src/models/reddy.R")
# models <- basic
prepend_to_directory(models, "models/reddy")

# Select best model based on validated predictions
data$cohort <- "val_predict"
pan_ass_scalar$file <-  "results/reddy/panta_val.csv"
# eval_tbl <- pan_ass_scalar$assess_center(data, models)

# Assess it on the test data
data$cohort <- "test"
pan_ass_scalar$file <- "results/reddy/panta_test.csv"
# models <- models[eval_tbl[["model"]][1]]
# pan_ass_scalar$assess_center(data, models)

val_vs_test(
    model_list = models,
    data = data,
    error_fun = neg_prec_with_prev_greater(0.17),
    spotlight_regex = "gauss-cox|gauss-gauss",
    file = "results/reddy/meta_gauss-glm.jpeg",
    spotlight_name = "gauss-[glm]",
    plot_theme = theme,
    colors = colors
)
# val_vs_test(
#     model_list = models,
#     data = data,
#     error_fun = neg_prec_with_prev_greater(0.17),
#     spotlight_regex = "gauss-rf",
#     file = "results/reddy/meta_gauss-rf.jpeg",
#     spotlight_name = "gauss-rf",
#     plot_theme = theme
# )
# val_vs_test(
#     model_list = models,
#     data = data,
#     error_fun = neg_prec_with_prev_greater(0.17),
#     spotlight_regex = "no expr",
#     file = "results/reddy/meta_no_expr.jpeg",
#     spotlight_name = "no RNA-seq",
#     plot_theme = theme
# )