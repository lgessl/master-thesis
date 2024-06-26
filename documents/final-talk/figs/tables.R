# Generate tables

source("../utils.R")

# IPI

lst <- jsonlite::fromJSON("../../data/schmitz/info.json")[[c("data", "benchmark", "performance")]]
tbl <- tibble::as_tibble(lst)
tbl <- tbl[1:6, 1:3]
names(tbl) <- c("IPI $\\geq$", "prevalence", "precision")

tibble2latex(
    tbl = tbl,
    file = "figs/ipi_schmitz.tex",
    caption = "Classifying PFS < 2 years on \\autocite{schmitz18}.",
    label = "fig:ipi-schmitz",
    digits = 2
)

# AUC

top_n <- 10

col_types <- paste0(c(rep("c", 3), rep("d", 4)), collapse = "")
auc_tbl <- readr::read_csv("../../results/schmitz/auc.csv", col_types = col_types)
auc_ei_tbl <- readr::read_csv("../../results/schmitz/ei_auc.csv", col_types = col_types)
auc_tbl <- dplyr::bind_rows(auc_tbl, auc_ei_tbl)
auc_tbl <- auc_tbl[order(auc_tbl[["mean"]], decreasing = TRUE), ]
auc_tbl <- cbind(rank = 1:nrow(auc_tbl), auc_tbl)
readr::write_csv(auc_tbl, "figs/auc.csv") # for my own analysis
auc_tbl <- auc_tbl[seq(top_n), c(1, 2, 4, 5)]
names(auc_tbl)[c(3, 4)] <- c("$T$", "AUC")
auc_tbl <- auc_tbl[1:top_n, ]

tibble2latex(
    tbl = auc_tbl,
    file = "figs/auc_table.tex",
    caption = "Split into train and test cohort, train a model on train cohort, calculate ROC-AUC
        on test cohort. Repeat this 15 times and average.",
    label = "fig:top-auc-schmitz",
    align = "rlrr",
    digits = 3
)