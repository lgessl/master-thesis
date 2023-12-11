# General PerfPlotSpec you can use to assess the performance of any model

std_pps <- PerfPlotSpec(
    fname = "results/all/prev_vs_precison.pdf",
    x_metric <- "rpp",
    y_metric <- "prec",
    pfs_leq <- 2.
)