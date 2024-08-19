# Initialize AssScalar and Ass2d objects
# Ass2d objects specify a 2d plot, therefore also define plot themes

loadNamespace("ranger")
loadNamespace("zeroSum")

use_fira_sans <- TRUE

# Useful colors
metropolis_colors <- c("#1c2d30", "#33b8ff", "#14B03D", "#604c38")
metropolis_bright_bg <- grDevices::rgb(250, 250, 250, maxColorValue = 255)

# The font: Fira Sans (end of discussion)
if (use_fira_sans) {
    font_family <- "Fira Sans"
    sysfonts::font_add("Fira Sans", regular = "FiraSans-Regular.ttf", bold = "FiraSans-Bold.ttf")
} else {
    font_family <- NULL
}

# Important lengths for the thesis
cm_per_point <- 0.0352777778
thesis_textwidth <- 393 * cm_per_point
thesis_textheight <- 641 * cm_per_point

# Useful plot themes
plot_themes <- list()
plot_themes[["thesis"]] <- ggplot2::theme_light() +
    ggplot2::theme(
        text = ggplot2::element_text(
            family = font_family, 
            color = "black", 
            size = 8
        ),
        legend.spacing.y = grid::unit(-0.2, "cm"),
        legend.spacing.x = grid::unit(-0.5, "cm"),
        legend.key.height = ggplot2::unit(0.55, "lines"),
        plot.title = ggplot2::element_text(size = 8),
        axis.title = ggplot2::element_text(size = 7),
        # axis.text = element_text(size = 8),
        legend.title = ggplot2::element_text(size = 7, margin = ggplot2::margin(b = 0.1, unit = "cm")),
        legend.box.spacing = grid::unit(0.0, "cm"),
        legend.text = ggplot2::element_text(margin = ggplot2::margin(l = -0.1, unit = "cm"))
    )
plot_themes[["patchwork_title"]] <- plot_themes[["thesis"]] +
    ggplot2::theme(
        plot.title = ggplot2::element_text(size = 9)
    )
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

# Ass2d objects
# Prevalence in [0.10, 0.50] vs. precision
prev_prec_as2 <- Ass2d$new(
    x_metric = "rpp",
    y_metric = "prec",
    xlim = c(0.10, 0.50),
    x_lab = "prevalence",
    y_lab = "precision",
    theme = plot_themes[["thesis"]]
)
# Prevalence in [0.10, 0.50] vs. lower limit of precision 95%-CI
prec_ci_as2 <- Ass2d$new(
    x_metric = "rpp",
    y_metric = "precision_ci",
    xlim = c(0.10, 0.50),
    x_lab = "prevalence",
    y_lab = "lower limit of precision CI",
    theme = plot_themes[["thesis"]],
    confidence_level = 0.95
)

# AssScalar objects
# Threshold model in such a way that precision with prevalence in [0.17, 1] is maximized, 
# calculate a bunch of metrics
pan_ass_scalar <- AssScalar$new(
    metrics = c("precision", "prevalence", "precision_ci_ll", "precision_ci_ul", "hr", "hr_ci_ll", 
        "hr_ci_ul", "hr_p", "auc", "logrank", "accuracy", "threshold", "n_samples", "perc_true"),
    prev_range = c(0.17, 1),
    round_digits = 5, 
    file = "panta.csv",
    benchmark = list(name = "ipi", "prev_range" = c(0.10, 1))
)
# Only with our prime metric to quickly get a validation ranking
prec_ass_scalar <- AssScalar$new(
    metric = "precision",
    prev_range = c(0.17, 1),
    round_digits = 5,
    file = NULL,
    benchmark = NULL
)