# Generate the tables holding AUCs

top_n <- 12

col_types <- paste0(c(rep("c", 3), rep("d", 4)), collapse = "")
auc_tbl <- readr::read_csv("results/schmitz/auc.csv", col_types = col_types)
auc_ei_tbl <- readr::read_csv("results/schmitz/ei_auc.csv", col_types = col_types)
auc_tbl <- dplyr::bind_rows(auc_tbl, auc_ei_tbl)
auc_tbl <- auc_tbl[order(auc_tbl[["mean"]], decreasing = TRUE), ]
rownames(auc_tbl) <- seq(nrow(auc_tbl))
auc_tbl <- auc_tbl[seq(top_n), c(1, 3, 4)]
names(auc_tbl)[3] <- "AUC (mean)"

c <- print(
    xtable::xtable(
        auc_tbl, 
        digits = 3, 
        caption = "Top models ranked by ROC-AUC on test cohort. Mean is taken over 15 splits into train and test cohort (ratio 2:1).",
        label = "fig:auc-schmitz"
    )
)

c <- stringr::str_replace(c, "& model", "rank & model")
f <- file("documents/progress-report/figs/auc_table.tex")
writeLines(c, f)
close(f)

