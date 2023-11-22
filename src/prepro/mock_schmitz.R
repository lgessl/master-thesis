# Generate mock data from the preprocessed Schmitz et al. (2016) DLBCL RNA-seq data

library(lymphomaSurvivalPipeline)

set.seed(48975)

directory <- "data/schmitz"
n_samples <- 50
n_genes <- 10
expr_fname <- "expr.csv"
pheno_fname <- "pheno.csv"
save_suffix <- "mock"
directory_lsp <- "../lymphomaSurvivalPipeline/tests/testthat/data/schmitz"

mock_data <- mock_data_from_existing(
    directory,
    n_samples = n_samples,
    n_genes = n_genes
)

if(dir.exists(directory_lsp)){
    cat("Writing mock data into", directory_lsp, "...\n")
    to_files <- c(
        expr_fname,
        pheno_fname
    )
    for(i in 1:2){
        cat("... as", to_files[i], "\n")
        from <- file.path(directory, mock_data[["file_names"]][i])
        to <- file.path(directory_lsp, to_files[i])
        file.rename(from = from, to = to)
    }
}