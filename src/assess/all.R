# Assess models on combined big data set

library(patroklos)

source("src/assess/ass.R")

data <- readRDS("data/all/data.rds")

# Trained on lamis
source("src/models/all.R")
prepend_to_directory(models, "models/all/on_lamis")
data$cohort <- "val_predict"
pan_ass_scalar$file <- "results/all/lamis_val_predict.csv"
val_tbl <- pan_ass_scalar$assess_center(data, models)
data$cohort <- "schmitz"
val_vs_test(
    model_list = models,
    data = data,
    error_fun = neg_prec_with_prev_greater(0.17),
    file = "results/all/lamis_vs_schmitz.jpeg",
    plot_theme = plot_themes[["presentation"]],
    colors = colors[2]
)
models <- models[c(val_tbl[["model"]][1], "ipi")]

# Assess this model on schmitz
data$cohort <- "schmitz"
pan_ass_scalar$file <- "results/all/lamis_on_schmitz.csv"
pan_ass_scalar$assess_center(data, models)

# Assess this model on reddy
data$cohort <- "reddy"
pan_ass_scalar$file <- "results/all/lamis_on_reddy.csv"
pan_ass_scalar$assess_center(data, models)

# Trained on schmitz
source("src/models/all.R")
prepend_to_directory(models, "models/all/on_schmitz")
data$cohort <- "val_predict"
pan_ass_scalar$file <- "results/all/schmitz_val_predict.csv"
val_tbl <- pan_ass_scalar$assess_center(data, models)
models <- models[c(val_tbl[["model"]][1], "ipi")]

# Assess this model on the lamis
data$cohort <- "lamis"
pan_ass_scalar$file <- "results/all/schmitz_on_lamis.csv"
pan_ass_scalar$assess_center(data, models)

# Assess this model on reddy
data$cohort <- "reddy"
pan_ass_scalar$file <- "results/all/schmitz_on_reddy.csv"
pan_ass_scalar$assess_center(data, models)

# Trained on reddy
source("src/models/all.R")
prepend_to_directory(models, "models/all/on_reddy")
data$cohort <- "val_predict"
pan_ass_scalar$file <- "results/all/reddy_val_predict.csv"
val_tbl <- pan_ass_scalar$assess_center(data, models)
data$cohort <- "lamis"
val_vs_test(
    model_list = models,
    data = data,
    error_fun = neg_prec_with_prev_greater(0.17),
    file = "results/all/reddy_vs_lamis.jpeg",
    plot_theme = plot_themes[["thesis"]],
    colors = colors[2]
)
models <- models[c(val_tbl[["model"]][1], "ipi")]

# Assess this model on the lamis
data$cohort <- "lamis"
pan_ass_scalar$file <- "results/all/reddy_on_lamis.csv"
pan_ass_scalar$assess_center(data, models)

# Assess this model on schmitz
data$cohort <- "schmitz"
pan_ass_scalar$file <- "results/all/reddy_on_schmitz.csv"
pan_ass_scalar$assess_center(data, models)