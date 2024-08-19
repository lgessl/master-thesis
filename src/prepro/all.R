# Combine Schmitz, Reddy and Staiger into one dataset
# Schmitz, Reddy, Staiger need to have been preprocessed in advance

library(patroklos)

schmitz <- readRDS("data/schmitz/data.rds")$read()
reddy <- readRDS("data/reddy/data.rds")$read()
staiger <- readRDS("data/staiger/data.rds")$read()

if (!dir.exists("data/all")) dir.create("data/all")

# Map gene names to HGNC (only need to do this for Reddy)
ensemble <- biomaRt::useMart("ensembl", dataset = "hsapiens_gene_ensembl")
mapping <- biomaRt::getBM(attributes = c("ensembl_gene_id", "hgnc_symbol"), 
    filters = "ensembl_gene_id", values = colnames(reddy$expr_mat), mart = ensemble)
reddy$expr_mat <- reddy$expr_mat[, colnames(reddy$expr_mat) %in% mapping[["ensembl_gene_id"]]]
reddy$expr_mat <- reddy$expr_mat[, mapping[["ensembl_gene_id"]]]
colnames(reddy$expr_mat) <- mapping[["hgnc_symbol"]]

# Unite expr_mat and pheno_tbl
colnames(schmitz$pheno_tbl)[colnames(schmitz$pheno_tbl) == "pfs_years"] <- "survival_years"
colnames(reddy$pheno_tbl)[colnames(reddy$pheno_tbl) == "os_years"] <- "survival_years"
colnames(staiger$pheno_tbl)[colnames(staiger$pheno_tbl) == "pfs_years"] <- "survival_years"
common_genes <- colnames(schmitz$expr_mat)
common_pheno_feat <- colnames(schmitz$pheno_tbl)
for (dset in list(reddy, staiger)) {
    common_genes <- intersect(common_genes, colnames(dset$expr_mat))
    common_pheno_feat <- intersect(common_pheno_feat, colnames(dset$pheno_tbl))
}
expr_mat <- matrix(nrow = 0, ncol = length(common_genes))
colnames(expr_mat) <- common_genes
pheno_mat <- matrix(nrow = 0, ncol = length(common_pheno_feat))
colnames(pheno_mat) <- common_pheno_feat
pheno_tbl <- tibble::as_tibble(pheno_mat)
dsets <- list(schmitz = schmitz, reddy = reddy, staiger = staiger)
for (i in seq_along(dsets)) {
    dsets[[i]]$pheno_tbl[["patient_id"]] <- paste0(names(dsets)[[i]], "_", 
        dsets[[i]]$pheno_tbl[["patient_id"]])
    rownames(dsets[[i]]$expr_mat) <- paste0(names(dsets)[[i]], "_", 
        rownames(dsets[[i]]$expr_mat))
    dsets[[i]]$pheno_tbl[["cohort"]] <- names(dsets)[[i]]
    expr_mat <- rbind(expr_mat, dsets[[i]]$expr_mat[, common_genes])
    pheno_tbl <- rbind(pheno_tbl, dsets[[i]]$pheno_tbl[, common_pheno_feat])
}
stopifnot(all(rownames(expr_mat) == pheno_tbl[["patient_id"]]))
ipi_group <- stringr::str_to_lower(pheno_tbl[["ipi_group"]])
ipi_group[ipi_group == "medium"] <- "intermediate"
pheno_tbl[["ipi_group"]] <- ipi_group
gender <- stringr::str_to_lower(pheno_tbl[["gender"]])
gender[gender == 0] <- "m"
gender[gender == 1] <- "f"
pheno_tbl[["gender"]] <- gender
abc <- stringr::str_to_lower(pheno_tbl[["gene_expression_subgroup"]])
abc[abc == "unclass"] <- "unclassified"
pheno_tbl[["gene_expression_subgroup"]] <- abc

cat("\nCategorical features have the following levels:\n")
for(i in seq_along(pheno_tbl)) {
    tab <- table(pheno_tbl[[i]])
    if (length(tab) < 10) {
        cat("\n", names(pheno_tbl)[i])
        print(tab)
    }
}

# Pack into Data object
data <- Data$new(
    name = "Schmitz & Reddy & Staiger",
    directory = "data/all",
    pivot_time_cutoff = 2,
    cohort = ".",
    cohort_col = "cohort", 
    benchmark_col = "ipi",
    time_to_event_col = "survival_years",
    event_col = "progression",
    imputer = mean_impute 
)
data$pheno_tbl <- pheno_tbl
data$expr_mat <- expr_mat

fname <- file.path(data$directory, "data.rds")
cat("Writing data to ", fname, "\n")
if (!dir.exists("data/all")) dir.create(data$directory)
saveRDS(data, fname)
