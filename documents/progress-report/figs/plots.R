# Generate plots

library(lymphomaSurvivalPipeline)

data_spec <- readRDS("data/schmitz/data_spec.rds")
source("src/train/model_spec.R") # logistic@1.75
source("src/assess/ass_spec.R") # prec_ci_as2, rpp_prec_as2, logrank_as2

dir <- "documents/progress-report/figs"

logistic$directory <- file.path("models/schmitz", logistic$directory, "1-75")
logistic$time_cutoffs <- 1.75
logistic$name <- c("logistic, T = 1.75")

data_spec$cohort <- "test"
data <- read(data_spec)

for(as2 in as2_list){
    as2$file <- file.path(dir, as2$file)
    as2$x_lab <- "prevalence"
    as2$title <- ""
    as2$alpha <- .13
    assess_2d(
        expr_mat = data[["expr_mat"]],
        pheno_tbl = data[["pheno_tbl"]],
        data_spec = data_spec,
        model_spec = logistic,
        ass_spec_2d = as2
    )
}