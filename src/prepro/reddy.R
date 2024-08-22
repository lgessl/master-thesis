# Preprocess, store and split 562 DLBCL RNA-seq bulks used by Reddy et al. (2017), 
# DOI: 10.1016/j.cell.2017.09.027

# This script yields the following files in data/reddy: 
# - two csv files with preprocessed pheno and expression data, expr.csv and pheno.csv
# - an rds file tracking the split into train and test cohort, cohort.rds, 
# - one json file with meta info, info.json,
# - an rds file holding the whole Data object with expr_mat, pheno_tbl read in, data.rds,
# - an rda file with the raw data, reddy.rda.

library(patroklos)

set.seed(234)

data_dir <- "data/reddy"
volume_data_dir <- "/data/mmml-predict/reddy" # on volume shared across spang lab compute servers
raw_fname <- "reddy.rda"
clean <- FALSE
only_with_survival_analysis <- TRUE
training_prop <- 0.75 
pivot_time_cutoff <- 2.5
time_to_event_col <- "os_years"
event_col <- "progression"
benchmark_col <- "ipi"
ipi_feat_cols <- c("age", "ann_arbor_stage", "ldh_ratio", "ecog_performance_status", 
    "n_extranodal_sites")

pheno_colnames_mapper <- c(
    ipi_group = "ipi_groups",
    gene_expression_subgroup = "abc_gcb_rnaseq",
    age = "age_at_diagnosis",
    `ann_arbor_stage>2` = "annarbor_stage_ipi",
    `age>60` = "age_ipi",
    `ldh_ratio>1` = "ldh_ipi",
    `ecog_performance_status>1` = "ecog_ipi",
    `n_extranodal_sites>1` = "multiple_extranodal_ipi",
    os_years = "overall_survival_years",
    progression = "censored"
)

if(!dir.exists(data_dir)){
    cat("Creating directory", data_dir, "\n")
    dir.create(data_dir)
}

cat("Reading in data\n")
full_fpath <- file.path(data_dir, raw_fname)
if (!file.exists(full_fpath)) {
    volume_fname <- file.path(volume_data_dir, raw_fname)
    if (file.exists(volume_fname)) {
        cat("Copying rda file from volume mounted into spang lab compute servers to", 
            full_fpath, "\n")
        file.copy(volume_fname, full_fpath)
    } else {
        stop("Cannot access data")
    }
}
load(file.path(full_fpath))
expr_tbl <- tibble::as_tibble(expr.mat.samples.624.norm, rownames = "gene_id")
pheno_tbl <- tibble::as_tibble(clinical.data.samples.624, rownames = "patient_id")

# Tidy up
cat("Tidying up\n")
# Pheno
names(pheno_tbl) <- names(pheno_tbl) |> 
    stringr::str_to_lower() |>
    stringr::str_replace_all("\\.| ", "_") |> 
    stringr::str_replace_all("_+", "_") |>
    stringr::str_remove("_$")
pheno_tbl <- pheno_tbl |> dplyr::rename(tidyselect::all_of(pheno_colnames_mapper))
# Censoring, not progression so far
pheno_tbl[["progression"]] <- as.numeric(xor(pheno_tbl[["progression"]], 1))
if(only_with_survival_analysis){
    pheno_tbl <- pheno_tbl[pheno_tbl[[time_to_event_col]] > 0 & !is.na(pheno_tbl[[time_to_event_col]]) & 
        !is.na(pheno_tbl[[event_col]]), ]
}

# Assimilate expression and pheno data
res <- ensure_patients_match(expr_tbl, pheno_tbl)
expr_tbl <- res[["expr_tbl"]]
pheno_tbl <- res[["pheno_tbl"]]

data <- Data$new(
    name = "Reddy et al. (2017)",
    directory = data_dir,
    cohort = ".",
    pivot_time_cutoff = pivot_time_cutoff,
    benchmark_col = benchmark_col,
    time_to_event_col = time_to_event_col,
    event_col = event_col,
    cohort_col = "cohort",
    imputer = mean_impute
)
data$pheno_tbl <- pheno_tbl
data$expr_mat <- t(as.matrix(expr_tbl[, -1]))
colnames(data$expr_mat) <- expr_tbl[["gene_id"]]

# Add LAMIS signature
if ("toscdata" %in% installed.packages()[, "Package"]) {
    lamis_sig <- toscdata::lamis_signature
} else {
    if (!file.exists("/data/mmml-predict/toscdata4mmml.rds")) 
        stop("You either need to have the toscdata package installed or be on a spang-lab ", 
            "compute server")
    lamis_sig <- readRDS("/data/mmml-predict/toscdata4mmml.rds")["lamis_signature"]
}
# Map gene names to HGNC (only need to do this for Reddy)
ensemble <- biomaRt::useMart("ensembl", dataset = "hsapiens_gene_ensembl")
mapping <- biomaRt::getBM(attributes = c("ensembl_gene_id", "hgnc_symbol"), 
    filters = "ensembl_gene_id", values = colnames(data$expr_mat), mart = ensemble)
data$expr_mat <- data$expr_mat[, colnames(data$expr_mat) %in% mapping[["ensembl_gene_id"]]]
data$expr_mat <- data$expr_mat[, mapping[["ensembl_gene_id"]]]
colnames(data$expr_mat) <- mapping[["hgnc_symbol"]]
# Calculate LAMIS score for available genes
cat("\nAre all LAMIS genes in Reddy after mapping from Ensembl to HGNC? ")
cat(all(names(lamis_sig) %in% colnames(data$expr_mat)))
cat("\nMissing are:\n")
print(lamis_sig[!names(lamis_sig) %in% colnames(data$expr_mat)])
lamis4reddy <- lamis_sig[names(lamis_sig) %in% colnames(data$expr_mat)]
data$pheno_tbl[["lamis_score"]] <- (data$expr_mat[, names(lamis4reddy)] %*% lamis4reddy)[, 1]
data$pheno_tbl[["lamis_high"]] <- (data$pheno_tbl[["lamis_score"]] > 
    quantile(data$pheno_tbl[["lamis_score"]], 0.75)) * 1

data$qc_preprocess(expr_tbl)
data$split(train_prop = training_prop, save = TRUE, keep_risk = TRUE)

write_data_info(
    filename = file.path(data_dir, "info.json"),
    data = data,
    expr_tbl = expr_tbl
)

cat("Writing preprocessed data to", data_dir, "\n")
readr::write_csv(data$pheno_tbl, file.path(data_dir, "pheno.csv"))
readr::write_csv(expr_tbl, file.path(data_dir, "expr.csv"))
data$read()
saveRDS(data, file.path(data_dir, "data.rds"))

if(clean){
    cat("Removing downloaded files\n")
    file.remove(file.path(data_dir, raw_fname))
}
