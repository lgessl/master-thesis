# General PerfPlotSpec you can use to assess the performance of any model

colors <- unicol::uni_regensburg_2[c(
        "glutrot",
        "tuerkisgruen",
        "capriblau",
        "laerchennadelgruen",
        "eisvogelblau",
        "blattgruen",
        "spektralblau",
        "urangelb",
        "heucherarot"
    )] |> unname()

rpp_prec_pps <- PerfPlotSpec(
    fname = "precision.jpeg",
    x_metric = "rpp",
    y_metric = "prec",
    pivot_time_cutoff = 2.,
    benchmark = "ipi",
    xlim = c(0, .5),
    x_lab = "rate of positive predictions",
    y_lab = "precision",
    fellow_csv = FALSE,
    scores_plot = FALSE,
    smooth_method = "loess",
    smooth_benchmark = TRUE,
    alpha = .075,
    colors = colors
)

logrank_pps <- PerfPlotSpec(
    fname = "logrank.jpeg",
    x_metric = "rpp",
    y_metric = "logrank",
    pivot_time_cutoff = 2.,
    benchmark = "ipi",
    xlim = c(0, .5),
    ylim = c(1e-4, 1), # try with 0 in the future
    x_lab = "rate of positive predictions",
    y_lab = "p-value (logrank test)",
    fellow_csv = FALSE,
    scores_plot = FALSE,
    smooth_method = "loess",
    smooth_benchmark = TRUE,
    scale_y = "log10",
    hline = list(yintercept = .05, linetype = "dashed", color = "black"),
    text = list(ggplot2::aes(x = .48, y = .05, label = "p = 0.05"), 
        inherit.aes = FALSE, size = 3),
    alpha = .075,
    colors = colors
)

prec_ci_pps <- PerfPlotSpec(
    fname = "precision_ci.jpeg",
    x_metric = "rpp",
    y_metric = "precision_ci",
    pivot_time_cutoff = 2.,
    benchmark = NULL,
    xlim = c(0, .5),
    x_lab = "rate of positive predictions",
    y_lab = "precision 95%-CI boundary",
    fellow_csv = FALSE,
    scores_plot = FALSE,
    smooth_method = "loess",
    smooth_benchmark = TRUE,
    hline = list(yintercept = 0.351, linetype = "dashed", color = "black"),
    text = list(ggplot2::aes(x = .4, y = .351, label = "IPI-45 (DSNHNL)"),
        inherit.aes = FALSE, size = 3),
    alpha = .075,
    colors = colors
)

pps_list <- list(
    "rpp_prec" = rpp_prec_pps,
    "logrank_pps" = logrank_pps,
    "prec_ci_pps" = prec_ci_pps
)
