# Apply zero-sum regression for LASSO-regularized Cox proportional hazards model 
# on Schmitz DLBCL bulk RNAseq data

library(zeroSum)

io <- modules::use("src/helpers/io.R")
assess <- modules::use("src/helpers/assess_model.R")


data_path <- "data/schmitz"
train_dir <- "train"
test_dir <- "test"
expr_fname <- "expr.csv"
pheno_fname <- "pheno.csv"
result_dir <- "results/cox-lasso-zerosum/schmitz"
model_file <- "model.rds" # in result_dir
use_existent_model <- TRUE # if available

if(!dir.exists(result_dir)){
    dir.create(result_dir, recursive=TRUE)
}
model_file <- file.path(result_dir, model_file)

# Training

tr <- io$read_data(data_path, train_dir)
tr <- io$prepare_data(tr$expr, tr$pheno)
if(!file.exists(model_file)){
    fit <- zeroSum::zeroSum(
        x = tr$x,
        y = tr$y,
        family = "cox",
        alpha = 1
    )
    saveRDS(fit, model_file)
} else {
    fit <- readRDS(model_file)
}

# Testing

te <- io$read_data(data_path, test_dir)
te <- io$prepare_data(te$expr, te$pheno, with_follow_up = TRUE)
# Positive class (pfs <= 2 yrs) belongs to high scores
predicted <- predict(fit, te$x)
# Higher labels belong to positive class (TRUE > FALSE)
labels <- te$y[, "pfs_yrs"] <= 2
assess$assess_model(
    predicted,
    labels,
    result_dir
)
