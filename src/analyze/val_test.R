library(patroklos)
library(patchwork)

generate_plot_list <- function(
    data_sets,
    data_cohorts,
    models_subset,
    regex1_list,
    regex2_list,
    name1_list,
    name2_list,
    legendtitle1_list,
    legendtitle2_list,
    error_fun = neg_prec_with_prev_greater(0.17),
    plot_theme = plot_themes[["thesis"]]
){
    plt_list <- list()
    for (i in seq_along(data_sets)) {
        data <- data_sets[[i]]
        data$cohort <- data_cohorts[[i]]
        source(paste0("src/models/", names(data_sets)[[i]], ".R"), local = TRUE)
        models <- models[models_subset]
        for (j in seq_along(regex2_list)) {
            plt <- val_vs_test(
                model_list = models,
                data = data,
                error_fun = neg_prec_with_prev_greater(0.17),
                regex1 = regex1_list[[j]],
                regex2 = regex2_list[[j]],
                name1 = name1_list[[j]],
                name2 = name2_list[[j]],
                legendtitle1 = legendtitle1_list[[j]],
                legendtitle2 = legendtitle2_list[[j]],
                correlation_label = FALSE,
                file = NULL,
                plot_theme = plot_theme,
                return_type = "ggplot"
            )
            plt <- plt + ggsci::scale_color_lancet()
            plt_list <- c(plt_list, list(plt))
        }
    }
    return(plt_list)
}

source("src/assess/ass.R")

schmitz <- readRDS("data/schmitz/data.rds")
reddy <- readRDS("data/reddy/data.rds")
lamis_test2 <- readRDS("data/lamis_test2/data.rds")
data_sets <- list(schmitz = schmitz, reddy = reddy, lamis_test2 = lamis_test2)
# data_sets <- list(lamis_test2 = lamis_test2, lamis_test2 = lamis_test2, lamis_test2 = lamis_test2)

# GE only
models_subset <- c("cox", "cox std", "log", "log std", "gauss", "gauss std", "cox ridge", 
    "cox std ridge", "log ridge", "log std ridge", "gauss ridge", "gauss std ridge")
# spot 1: model class
mclass_regex <- c("cox", "gauss", "log")
regex1_list <- list(mclass_regex, mclass_regex)
mclass_name <- c("Cox", "Gauss", "Logistic")
name1_list <- list(mclass_name, mclass_name)
# spot 2: 
# (a) elastic-net regularization
enet_regex <- c("ridge", ".")
enet_name <- c("ridge", "LASSO")
# (b) standardize X
std_regex <- c("std", ".")
std_name <- c("yes", "no")
regex2_list <- list(enet_regex, std_regex)
name2_list <- list(enet_name, std_name)
legendtitle1_list <- list("model class", "model class")
legendtitle2_list <- list("regularization", "standardize X")


plt_list <- generate_plot_list(
    data_sets = data_sets,
    data_cohorts = c("test", "test", "test"),
    models_subset = models_subset,
    regex1_list = regex1_list,
    regex2_list = regex2_list,
    name1_list = name1_list,
    name2_list = name2_list,
    legendtitle1_list = legendtitle1_list,
    legendtitle2_list = legendtitle2_list
)
# Create sub-grids for each row
row1 <- wrap_elements(plt_list[[1]] + plt_list[[2]] + plot_annotation(title = "A \u2013 Schmitz", 
    theme = plot_themes[["thesis"]]))
row2 <- wrap_elements(plt_list[[3]] + plt_list[[4]] + plot_annotation(title = "B \u2013 Reddy", 
    theme = plot_themes[["thesis"]]))
row3 <- wrap_elements(plt_list[[5]] + plt_list[[6]] + plot_annotation(title = "C \u2013 Lamis test", 
    theme = plot_themes[["thesis"]]))

# Combine the sub-grids into the final patchwork grid with titles for each row
pw <- row1 / row2 / row3
showtext::showtext_auto()
ggplot2::ggsave(pw, file = "results/intra_val_test_geo.pdf", 
    width = thesis_textwidth, height = thesis_textheight * 0.65, units = "cm")
showtext::showtext_auto(FALSE)

# More features 
# Schmitz & Reddy
data_sets <- list(schmitz = schmitz, reddy = reddy)
# data_sets <- list(reddy = reddy)
# (a) model architecture, just one spot
model_arch <- c("gauss-(gauss|log|cox)", "gauss-rf", "rf ei", "log", "cox", "gauss")
model_arch_name <- c("Gauss-GLM", "Gauss-RF", "RF", "Logistic", "Cox", "Gauss")
# (b) included features
features <- c("no expr", "with", ".")
features_name <- c("no GE", "GE & more", "GE only")
regex1_list <- list(model_arch, features)
name1_list <- list(model_arch_name, features_name)
legendtitle1_list <- list("architecture", "features") 
regex2_list <- list(NULL, NULL)
name2_list <- list(NULL, NULL)
legendtitle2_list <- list(NULL, NULL)

plt_list <- generate_plot_list(
    data_sets = data_sets,
    data_cohorts = c("test", "test"),
    models_subset = TRUE,
    regex1_list = regex1_list,
    regex2_list = regex2_list,
    name1_list = name1_list,
    name2_list = name2_list,
    legendtitle1_list = legendtitle1_list,
    legendtitle2_list = legendtitle2_list
)

# Lamis test
data_sets <- list(lamis_test2 = lamis_test2)
# (a) model architecture, just one spot
model_arch <- c("cox-(gauss|log|cox)", "cox-rf", "rf ei", "log", "cox", "gauss")
model_arch_name <- c("Cox-GLM", "Cox-RF", "RF", "Logistic", "Cox", "Gauss")
# (b) included features (reuse from above)
regex1_list <- list(model_arch, features)
name1_list <- list(model_arch_name, features_name)

plt_list <- c(plt_list, generate_plot_list(
    data_sets = data_sets,
    data_cohorts = c("test"),
    models_subset = TRUE,
    regex1_list = regex1_list,
    regex2_list = regex2_list,
    name1_list = name1_list,
    name2_list = name2_list,
    legendtitle1_list = legendtitle1_list,
    legendtitle2_list = legendtitle2_list
))

# Create sub-grids for each row
row1 <- wrap_elements(plt_list[[1]] + plt_list[[2]] + plot_annotation(title = "A \u2013 Schmitz", 
    theme = plot_themes[["thesis"]]))
row2 <- wrap_elements(plt_list[[3]] + plt_list[[4]] + plot_annotation(title = "B \u2013 Reddy", 
    theme = plot_themes[["thesis"]]))
row3 <- wrap_elements(plt_list[[5]] + plt_list[[6]] + plot_annotation(title = "C \u2013 Lamis test", 
    theme = plot_themes[["thesis"]]))

# Combine the sub-grids into the final patchwork grid with titles for each row
pw <- row1 / row2 / row3
showtext::showtext_auto()
ggplot2::ggsave(pw, file = "results/intra_val_test_more.pdf", 
    width = thesis_textwidth, height = thesis_textheight * 0.65, units = "cm")
showtext::showtext_auto(FALSE)