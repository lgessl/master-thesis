# Generate plots

library(patroklos)

data <- readRDS("../../data/schmitz/data.rds")
source("../../src/train/models.R") # logistic@1.75
source("../../src/assess/ass.R") # prec_ci_ass2d, rpp_prec_ass2d, logrank_ass2d

dir <- "figs"

logistic$directory <- file.path("../../models/schmitz", logistic$directory, "1-75")
logistic$time_cutoffs <- 1.75
logistic$name <- c("logistic, T = 1.75")

data$cohort <- "test"
data$directory <- file.path("../..", data$directory)
data$read()

for(ass2d in ass2d_list){
    ass2d$file <- file.path(dir, ass2d$file)
    ass2d$x_lab <- "prevalence"
    ass2d$title <- ""
    ass2d$alpha <- .13
    ass2d$dpi <- 400
    ass2d$assess(data, logistic)
}