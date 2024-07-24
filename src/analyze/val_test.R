library(patroklos)
library(patchwork)

source("src/assess/ass.R")

schmitz <- readRDS("data/schmitz/data.rds")
reddy <- readRDS("data/reddy/data.rds")
lamis_test2 <- readRDS("data/lamis_test2/data.rds")
data_sets <- list(schmitz = schmitz, reddy = reddy, lamis_test2 = lamis_test2)
data_sets <- list(lamis_test2 = lamis_test2)

# GE only
# spot 1: model class
mclass_regex <- c("cox", "gauss", "log")
mclass_name <- c("Cox", "Gaussian", "Logistic")
# spot 2: 
# (a) elastic-net regularization
enet_regex <- c("ridge", ".")
enet_name <- c("ridge", "LASSO")
# (b) standardize X
std_regex <- c("std", ".")
std_name <- c("yes", "no")
regex2_list <- list(enet = enet_regex, std = std_regex)
name_list <- list(enet = enet_name, std = std_name)
legendtitle2_list <- list(enet = "regularization", std = "standardize X")

plt_list <- list()
for (data_name in names(data_sets)) {
    data <- data_sets[[data_name]]
    data$cohort <- "test"
    source(paste0("src/models/", data_name, ".R"))
    models <- models[c("cox", "cox std", "log", "log std", "gauss", "gauss std", "cox ridge", 
        "cox std ridge", "log ridge", "log std ridge", "gauss ridge", "gauss std ridge")]
    for (regex2_name in names(regex2_list)) {
        file <- paste0("results/intra_ge_only_", data_name, "_", regex2_name, ".pdf")
        regex2 <- regex2_list[[regex2_name]]
        name2 <- name_list[[regex2_name]]
        legendtitle2 <- legendtitle2_list[[regex2_name]]
        plt <- val_vs_test(
            model_list = models,
            data = data,
            error_fun = neg_prec_with_prev_greater(0.17),
            regex1 = mclass_regex,
            regex2 = regex2,
            name1 = mclass_name,
            name2 = name2,
            legendtitle1 = "model class",
            legendtitle2 = legendtitle2,
            correlation_label = FALSE,
            file = NULL,
            plot_theme = plot_themes[["thesis"]],
            return_type = "ggplot"
        )
        plt_list <- c(plt_list, list(plt))
    }
}

showtext::showtext_auto()
ggplot2::ggsave(plt_list[[1]] + plt_list[[2]], file = "results/intra_ge_only_lamis.pdf", 
    width = 0.8 * 0.7 * thesis_textwidth, height = 0.8 * 0.6 * thesis_textheight/3*0.7)
showtext::showtext_auto(FALSE)
