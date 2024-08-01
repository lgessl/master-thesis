library(patroklos)
library(patchwork)

source("src/assess/ass.R")

data <- readRDS("data/all/data.rds")

train_cohort <- c("schmitz", "reddy", "lamis")
test_cohort <- list(c("reddy", "lamis"), c("schmitz", "lamis"), c("schmitz", "reddy"))

plt_list <- list()
source("src/models/all.R", local = TRUE)
for (i in seq_along(train_cohort)) {
    prepend_to_directory(models, paste0("models/all/on_", train_cohort[i]))
    data$cohort <- "val_predict"
    best_val_name <- prec_ass_scalar$assess_center(data, models)[1, "model"]
    best_val_model <- models[best_val_name]
    for (j in seq_along(test_cohort)) {
        data$cohort <- test_cohort[[i]][j]
        plt <- prec_prev_thesis_as2$assess(data, model)
        plt_list <- c(plt_list, plt)
    }
}