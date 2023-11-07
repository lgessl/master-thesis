import("ggplot2")
import("dplyr")
import("unigd")

assess_model <- function(
    predicted,
    labels,
    result_dir,
    prev_prec_plot = TRUE,
    prev_prec_csv = TRUE,
    roc_auc_plot = TRUE,
    show_plots = TRUE,
    width = 7,
    height = 4,
    units = "in",
    csv_round_n_digits = 3
){
    predicted <- ROCR::prediction(predicted, labels) # S4 class 'prediction'

    # prevalence vs true positive rate
    if(prev_prec_plot){
        fname <- file.path(result_dir, "prev_vs_prec.pdf")
        prev_vs_prec <- ROCR::performance(predicted, measure = "prec", x.measure = "rpp")
        tbl <- tibble::tibble(
            "prevalence" = prev_vs_prec@x.values[[1]],
            "precision" = prev_vs_prec@y.values[[1]],
            "cutoff" = prev_vs_prec@alpha.values[[1]]
        )
        tbl <- tbl %>% filter(!is.na(precision))
        plt <- ggplot2::ggplot(
            tbl, 
            ggplot2::aes(x = prevalence, y = precision)
            ) +
            ggplot2::geom_line(col = "darkblue")
        ggplot2::ggsave(fname, plt, width = width, height = height, units = units)
        if(show_plots){
            print(plt)
        }
        if(prev_prec_csv){
            tbl <- tbl |> 
                mutate(
                    across(
                        everything(), 
                        ~round(.x, digits = csv_round_n_digits)
                        )
                    )
            fname <- file.path(result_dir, "prev_vs_prec.csv")
            readr::write_csv(
                tbl,
                file = fname
            )
        }
    }
    # ROC AUC curve
    if(roc_auc_plot){
        fname <- file.path(result_dir, "roc_auc.pdf")
        roc <- ROCR::performance(predicted, measure = "tpr", x.measure = "fpr")
        auc <- ROCR::performance(predicted, measure = "auc")
        auc <- round(auc@y.values[[1]], digits = 4)
        tbl <- tibble::tibble(
            "false positive rate" = roc@x.values[[1]],
            "true positive rate" = roc@y.values[[1]]
        )
        plt <- ggplot2::ggplot(
            tbl,
            ggplot2::aes(x = `false positive rate`, y = `true positive rate`)
            ) +
            ggplot2::geom_line(col = "darkred") +
            ggplot2::ggtitle(stringr::str_c("AUC = ", auc))
        ggplot2::ggsave(fname, plt, width = width, height = height, units = units)
        if(show_plots){
            print(plt)
        }
    }
}