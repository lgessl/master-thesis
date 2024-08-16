library(patroklos)
library(ggplot2)
library(patchwork)

source("src/assess/ass.R")

generate_pdf <- function(
    data,
    train_cohort,
    test_cohort,
    file,
    ass2d,
    benchmark_precision,
    vline_at
){
    row_list <- vector("list", 3)
    c_letters <- stringr::str_to_upper(letters)
    for (i in seq_along(train_cohort)) {
        print(train_cohort[i])
        source("src/models/all.R", local = TRUE)
        prepend_to_directory(models, paste0("models/all/on_", train_cohort[i]))
        data$cohort <- "val_predict"
        best_val_name <- prec_ass_scalar$assess_center(data, models)[["model"]][1]
        print(best_val_name)
        best_val_model <- models[[best_val_name]]
        plt_list <- vector("list", 2)
        for (j in seq_along(test_cohort[[i]])) {
            data$cohort <- test_cohort[[i]][j]
            plt <- ass2d$assess(data, best_val_model)
            plt <- plt + 
                ggplot2::geom_hline(yintercept = benchmark_precision[data$cohort], linetype = 
                    "dashed", color = "darkgray") +
                ggtitle(paste0(c_letters[i], ".", j, " \u2013 Tested on ", 
                stringr::str_to_title(data$cohort))) + ggsci::scale_color_lancet(guide = "none")
            if (!is.null(vline_at))
                plt <- plt + ggplot2::geom_vline(xintercept = vline_at, linetype = "dashed", 
                    color = "darkgray")
            plt_list[[j]] <- plt
        }
        row_list[[i]] <- wrap_elements(plt_list[[1]] + plt_list[[2]] +
            plot_annotation(title = paste0(c_letters[i], " \u2013 Trained on ", 
            stringr::str_to_title(train_cohort[i])), theme = plot_themes[["patchwork_title"]]))
    }
    pw <- row_list[[1]] / row_list[[2]] / row_list[[3]]
    showtext::showtext_auto()
    ggplot2::ggsave(pw, file = file, 
        width = thesis_textwidth, height = thesis_textheight * 0.775, units = "cm")
    showtext::showtext_auto(FALSE)
}

data <- readRDS("data/all/data.rds")

train_cohort <- c("schmitz", "reddy", "staiger")
test_cohort <- list(c("reddy", "staiger"), c("schmitz", "staiger"), c("schmitz", "reddy"))
ipi_prec <- c(schmitz = 0.652, reddy = 0.541, staiger = 0.382)
files <- c("results/inter_output_prec.pdf", "results/inter_output_prec_ci.pdf")
ass2d_list <- list(prev_prec_as2, prec_ci_as2)
vline_at <- list(NULL, NULL)

for (i in seq_along(files)) {
    generate_pdf(data, train_cohort, test_cohort, files[i], ass2d_list[[i]], ipi_prec, vline_at = 
        vline_at[[i]])
}