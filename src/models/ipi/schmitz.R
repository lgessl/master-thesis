# Assess the IPI on the Schmitz DLBCL bulk RNAseq test data

io <- modules::use("src/helpers/io.R")
assess <- modules::use("src/helpers/assess_model.R")


data_path <- "data/schmitz"
train_dir <- "train"
test_dir <- "test"
expr_fname <- "expr.csv"
pheno_fname <- "pheno.csv"
result_dir <- "results/ipi/schmitz"

pfs_cutoff <- 2.

if(!dir.exists(result_dir)){
    dir.create(result_dir, recursive=TRUE)
}

# Testing

te <- io$read_data(data_path, test_dir)
te <- io$prepare_data(te$expr, te$pheno, with_follow_up = TRUE, with_ipi = TRUE)
labels <- te$y[, "pfs_yrs"] <= pfs_cutoff
predicted <- te$y[, "ipi_group"]
assess$assess_model(predicted, labels, result_dir, with_points = TRUE)
