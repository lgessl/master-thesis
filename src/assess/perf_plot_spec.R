# General PerfPlotSpec you can use to assess the performance of any model

std_pps <- PerfPlotSpec(
    fname = "the_best.pdf",
    x_metric <- "rpp",
    y_metric <- "prec",
    pfs_leq <- 2.,
    x_lab = "rate of positive predictions",
    y_lab = "precision",
    smooth_method = "loess",
    smooth_benchmark = FALSE,
    alpha = .25,
    colors = unicol::uni_regensburg_2[c(
        "glutrot",
        "tuerkisgruen",
        "capriblau",
        "laerchennadelgruen",
        "eisvogelblau",
        "blattgruen"
    )] |> unname()
)
