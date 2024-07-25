loadNamespace("ranger")
loadNamespace("zeroSum")

uni_colors <- unicol::uni_regensburg_2[c(
        "glutrot",
        "tuerkisgruen",
        "capriblau",
        "laerchennadelgruen",
        "blattgruen",
        "spektralblau",
        "urangelb",
        "heucherarot"
    )] |> unname()
metropolis_colors <- c("#1c2d30", "#33b8ff", "#14B03D", "#604c38")
metropolis_bright_bg <- grDevices::rgb(250, 250, 250, maxColorValue = 255)
font_family <- "Fira Sans"

sysfonts::font_add("Fira Sans", regular = "FiraSans-Regular.ttf", bold = "FiraSans-Bold.ttf")
cm_per_point <- 0.0352777778
thesis_textwidth <- 393 * cm_per_point
thesis_textheight <- 641 * cm_per_point
colors <- c(metropolis_colors, uni_colors)
plot_themes <- list()
plot_themes[["presentation"]] <- ggplot2::theme_light() + 
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
            family = font_family,
            color = "black",
            size = 10
        )
    )
plot_themes[["thesis"]] <- ggplot2::theme_light() +
    ggplot2::theme(
        text = ggplot2::element_text(
            family = "Fira Sans", 
            color = "black", 
            size = 8
        ),
        legend.spacing.y = grid::unit(-0.2, "cm"),
        legend.spacing.x = grid::unit(-0.5, "cm"),
        legend.key.height = ggplot2::unit(0.55, "lines"),
        plot.title = ggplot2::element_text(size = 9),
        axis.title = ggplot2::element_text(size = 7),
        # axis.text = element_text(size = 8),
        legend.title = ggplot2::element_text(size = 7, margin = ggplot2::margin(b = 0.1, unit = "cm")),
        legend.box.spacing = grid::unit(0.0, "cm"),
        legend.text = ggplot2::element_text(margin = ggplot2::margin(l = -0.1, unit = "cm"))
    )

rpp_prec_as2 <- Ass2d$new(
    file = "precision.jpeg",
    x_metric = "rpp",
    y_metric = "prec",
    benchmark = "ipi",
    xlim = c(0, .5),
    x_lab = "rate of positive predictions",
    y_lab = "precision",
    text_size = 3,
    fellow_csv = FALSE,
    smooth_method = "loess",
    alpha = .075,
    colors = colors,
    theme = plot_themes[["thesis"]]
)

logrank_as2 <- Ass2d$new(
    file = "logrank.jpeg",
    x_metric = "rpp",
    y_metric = "logrank",
    benchmark = "ipi",
    xlim = c(0, .5),
    ylim = c(1e-4, 1), # try with 0 in the future
    x_lab = "rate of positive predictions",
    y_lab = "p-value (logrank test)",
    text_size = 3,
    fellow_csv = FALSE,
    smooth_method = "loess",
    scale_y = "log10",
    hline = list(yintercept = .05, linetype = "dashed", color = "black"),
    text = list(ggplot2::aes(x = .48, y = .05, label = "p = 0.05"), 
        inherit.aes = FALSE, size = 3, family = font_family),
    alpha = .075,
    colors = colors,
    theme = plot_themes[["thesis"]]
)

prec_ci_as2 <- Ass2d$new(
    file = "precision_ci.jpeg",
    x_metric = "rpp",
    y_metric = "precision_ci",
    benchmark = NULL,
    xlim = c(0, .5),
    x_lab = "rate of positive predictions",
    y_lab = "precision 95%-CI boundary",
    text_size = 3,
    fellow_csv = FALSE,
    smooth_method = "loess",
    hline = list(yintercept = 0.351, linetype = "dashed", color = "black"),
    text = list(ggplot2::aes(x = .4, y = .351, label = "IPI-45 (DSNHNL)"),
        inherit.aes = FALSE, size = 3, family = font_family),
    alpha = .075,
    colors = colors,
    theme = plot_themes[["thesis"]]
)

ass2d_list <- list(
    "rpp_prec" = rpp_prec_as2,
    "logrank_as2" = logrank_as2,
    "prec_ci_as2" = prec_ci_as2
)

auc_ass_scalar <- AssScalar$new(
    metrics = "auc",
    prev_range = c(0.15, 1),
    file = "auc.csv"
)

pan_ass_scalar <- AssScalar$new(
    metrics = c("precision", "prevalence", "auc", "logrank", "accuracy", "threshold", 
        "n_samples", "perc_true"),
    prev_range = c(0.17, 1),
    file = "panta.csv"
)

ass_scalar_list <- list(
    auc_ass_scalar,
    pan_ass_scalar
)