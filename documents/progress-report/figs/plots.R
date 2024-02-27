# Generate plots

library(lymphomaSurvivalPipeline)

data <- readRDS("../../data/schmitz/data.rds")
source("../../src/train/model_spec.R") # logistic@1.75
source("../../src/assess/ass_spec.R") # prec_ci_as2, rpp_prec_as2, logrank_as2

dir <- "figs"

logistic$directory <- file.path("../../models/schmitz", logistic$directory, "1-75")
logistic$time_cutoffs <- 1.75
logistic$name <- c("logistic, T = 1.75")

data$cohort <- "test"
data$directory <- file.path("../..", data$directory)
data <- read(data)

for(as2 in as2_list){
    as2$file <- file.path(dir, as2$file)
    # as2$file <- stringr::str_replace(as2$file, "\\..+$", ".pdf")
    as2$x_lab <- "prevalence"
    as2$title <- ""
    as2$alpha <- .13
    as2$dpi <- 400
    assess_2d(
        expr_mat = data[["expr_mat"]],
        pheno_tbl = data[["pheno_tbl"]],
        data = data,
        model_spec = logistic,
        ass_spec_2d = as2
    )
}
#