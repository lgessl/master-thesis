# General Ass2d$new you can use to assess the performance of any model

uni_colors <- unicol::uni_regensburg_2[c(
        "eisvogelblau",
        "glutrot",
        "tuerkisgruen",
        "capriblau",
        "laerchennadelgruen",
        "blattgruen",
        "spektralblau",
        "urangelb",
        "heucherarot"
    )] |> unname()
metropolis_colors <- c("#23373b", "#eb811b", "#14B03D", "#604c38")
metropolis_bright_bg <- grDevices::rgb(250, 250, 250, maxColorValue = 255)
font_family <- "Fira Sans"

colors <- c(metropolis_colors, uni_colors)
theme <- ggplot2::theme_light() + 
    ggplot2::theme(
        plot.background = ggplot2::element_rect(
            fill = metropolis_bright_bg,
            color = metropolis_bright_bg
        ),
        panel.background = ggplot2::element_rect(
            fill = metropolis_bright_bg,
            color = metropolis_bright_bg
        ),
        legend.background = ggplot2::element_rect(
            fill = metropolis_bright_bg,
            color = metropolis_bright_bg
        ),
        legend.box.background = ggplot2::element_rect(
            fill = metropolis_bright_bg,
            color = metropolis_bright_bg
        ),
        text = ggplot2::element_text(
            family = font_family
        )
    )

rpp_prec_as2 <- Ass2d$new(
    file = "precision.jpeg",
    x_metric = "rpp",
    y_metric = "prec",
    pivot_time_cutoff = 2.,
    benchmark = "ipi",
    xlim = c(0, .5),
    x_lab = "rate of positive predictions",
    y_lab = "precision",
    text_size = 3,
    fellow_csv = FALSE,
    scores_plot = FALSE,
    smooth_method = "loess",
    alpha = .075,
    colors = colors,
    theme = theme
)

logrank_as2 <- Ass2d$new(
    file = "logrank.jpeg",
    x_metric = "rpp",
    y_metric = "logrank",
    pivot_time_cutoff = 2.,
    benchmark = "ipi",
    xlim = c(0, .5),
    ylim = c(1e-4, 1), # try with 0 in the future
    x_lab = "rate of positive predictions",
    y_lab = "p-value (logrank test)",
    text_size = 3,
    fellow_csv = FALSE,
    scores_plot = FALSE,
    smooth_method = "loess",
    scale_y = "log10",
    hline = list(yintercept = .05, linetype = "dashed", color = "black"),
    text = list(ggplot2::aes(x = .48, y = .05, label = "p = 0.05"), 
        inherit.aes = FALSE, size = 3, family = font_family),
    alpha = .075,
    colors = colors,
    theme = theme
)

prec_ci_as2 <- Ass2d$new(
    file = "precision_ci.jpeg",
    x_metric = "rpp",
    y_metric = "precision_ci",
    pivot_time_cutoff = 2.,
    benchmark = NULL,
    xlim = c(0, .5),
    x_lab = "rate of positive predictions",
    y_lab = "precision 95%-CI boundary",
    text_size = 3,
    fellow_csv = FALSE,
    scores_plot = FALSE,
    smooth_method = "loess",
    hline = list(yintercept = 0.351, linetype = "dashed", color = "black"),
    text = list(ggplot2::aes(x = .4, y = .351, label = "IPI-45 (DSNHNL)"),
        inherit.aes = FALSE, size = 3, family = font_family),
    alpha = .075,
    colors = colors,
    theme = theme
)

ass2d_list <- list(
    "rpp_prec" = rpp_prec_as2,
    "logrank_as2" = logrank_as2,
    "prec_ci_as2" = prec_ci_as2
)

auc_ass_scalar <- AssScalar$new(
    metric = "get_auc",
    pivot_time_cutoff = 2
)

all_ass_scalar <- AssScalar$new(
    metric = c("accuracy", "precision", "auc", "logrank"),
    pivot_time_cutoff = 2
)

ass_scalar_list <- list(
    auc_ass_scalar,
    all_ass_scalar
)