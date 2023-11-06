# Apply zero-sum regression for Cox proportional hazards model on Schmitz DLBCL bulk RNAseq data

library(tidyverse)
library(zeroSum)
library(ROCR)

source("src/cox-lasso-zerosum/helpers.R")

data_path <- "data/schmitz"
train_dir <- "train"
test_dir <- "test"
expr_fname <- "expr.csv"
pheno_fname <- "pheno.csv"
result_dir <- "results/cox-lasso-zerosum/schmitz"


if(!dir.exists(result_dir))
    dir.create(result_dir, recursive=TRUE)

# Training

tr <- read_data(data_path, train_dir)
tr <- prepare_data(tr$expr, tr$pheno)
View(tr$y)
fit <- zeroSum::zeroSum(
    x = tr$x,
    y = tr$y,
    family = "cox",
    alpha = 1
)
saveRDS(fit, file.path(result_dir, "schmitz_fit.rds"))


# Testing

te <- read_data(data_path, test_dir)
te <- prepare_data(te$expr, te$pheno, follow_up = TRUE)
predicted <- zeroSum::predict(fit, te$x)
predicted <- ROCR::prediction(predicted, te$y[, "pfs_yrs"] <= 2)
tpr_vs_prev <- ROCR::performance(predicted, measure = "tpr", x.measure = "rpp")
sum(te$y[, "pfs_yrs"] <= 2)
cbind(tpr_vs_prev@x.values[[1]], tpr_vs_prev@y.values[[1]])
?performance
