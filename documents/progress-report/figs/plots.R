# Generate plots

library(lymphomaSurvivalPipeline)

data_spec <- readRDS("data/schmitz/data_spec.rds")
source("src/train/model_spec.R") # logistic@1.75
source("src/assess/ass_spec.R")

dir <- "documents/progress-report/figs"

logistic$directory <- file.path("models/schmitz", logistic$directory, "1-75")
logistic$time_cutoffs <- 1.75
logistic$name <- c("logistic, T = 1.75")

data_spec$cohort <- "test"
data <- read(data_spec)

prev_prec_as2 <- AssSpec2d(
    file = file.path(dir, "prev_vs_prec.jpeg"),
    x_metric = "rpp",
    y_metric = "prec",
    pivot_time_cutoff = 2.,
    benchmark = "ipi",
    xlim = c(0, .5),
    smooth_method = "loess",
    title = "",
    x_lab = "prevalence",
    y_lab = "precision",
    alpha = .075,
    colors = colors,
    text_size = 3
)
prec_ci_as2 <- AssSpec2d(
    file = file.path(dir, "precision_ci.jpeg"),
    x_metric = "rpp",
    y_metric = "precision_ci",
    pivot_time_cutoff = 2.,
    benchmark = NULL,
    xlim = c(0, .5),
    title = "",
    x_lab = "prevalence",
    y_lab = "precision 95%-CI boundary",
    fellow_csv = FALSE,
    scores_plot = FALSE,
    smooth_method = "loess",
    hline = list(yintercept = 0.351, linetype = "dashed", color = "black"),
    text = list(ggplot2::aes(x = .4, y = .351, label = "IPI-45 (DSNHNL)"),
        inherit.aes = FALSE, size = 3),
    alpha = .075,
    colors = colors,
    text_size = 3
)
logrank_as2 <- AssSpec2d(
    file = file.path(dir, "logrank.jpeg"),
    x_metric = "rpp",
    y_metric = "logrank",
    pivot_time_cutoff = 2.,
    benchmark = "ipi",
    xlim = c(0, .5),
    ylim = c(1e-4, 1), # try with 0 in the future
    title = "",
    x_lab = "prevalence",
    y_lab = "p-value (logrank test)",
    fellow_csv = FALSE,
    scores_plot = FALSE,
    smooth_method = "loess",
    scale_y = "log10",
    hline = list(yintercept = .05, linetype = "dashed", color = "black"),
    text = list(ggplot2::aes(x = .48, y = .05, label = "p = 0.05"), 
        inherit.aes = FALSE, size = 3),
    alpha = .075,
    colors = colors,
    text_size = 3
)

for(as2 in list(prev_prec_as2, prec_ci_as2, logrank_as2)){
    assess_2d(
        expr_mat = data[["expr_mat"]],
        pheno_tbl = data[["pheno_tbl"]],
        data_spec = data_spec,
        model_spec = logistic,
        ass_spec_2d = as2
    )
}