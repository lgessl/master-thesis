# Preprocess, store and split 562 DLBCL RNAseq bulks provided by Staiger et al. (2019) 
#  DOI: 10.1038/s41375-019-0573-y

# This script yields the following files in data/staiger: 
# - two csv files with preprocessed pheno and expression data, expr.csv and pheno.csv
# - an rds file tracking the split into train and test cohort, cohort.rds, 
# - one json file with meta info, info.json,
# - an rds file holding the whole Data object with expr_mat, pheno_tbl read in, data.rds.

library(patroklos)

set.seed(115)

data_dir <- "data/staiger"
clean <- FALSE
training_prop <- 0.75 
pivot_time_cutoff <- 2
time_to_event_col <- "pfs_years"
event_col <- "progression"
benchmark_col <- "ipi"

pheno_colnames_mapper <- c(
    `age>60` = "ipi_age",
    `ldh_ratio>1` = "ipi_ldh",
    `ecog_performance_status>1` = "ipi_ecog",
    `n_extranodal_sites>1` = "ipi_exbm",
    `ann_arbor_stage>2` = "ipi_stage",
    pfs_years = "pfs",
    progression = "pfs_stat",
    os_years = "os",
    efs_years = "efs",
    efs_progression = "efs_stat",
    progression_os = "os_stat",
    gene_expression_subgroup = "coo_label"
)

if(!dir.exists(data_dir)){
    cat("Creating directory", data_dir, "\n")
    dir.create(data_dir)
}

cat("Reading in data\n")
if ("toscdata" %in% installed.packages()[, "Package"]) {
    lamis_sig <- toscdata::lamis_signature
    df <- toscdata::lamis_test2_v2
} else {
    if (!file.exists("/data/mmml-predict/toscdata4mmml.rds")) 
        stop("You either need to have the toscdata package installed or be on a spang-lab ", 
            "compute server")
    toscdata4mmml <- readRDS("/data/mmml-predict/toscdata4mmml.rds")
    lamis_sig <- toscdata4mmml["lamis_signature"]
    df <- toscdata4mmml["lamis_test2_v2"]
}

cat("Cutting out pheno and expression data\n")
pheno_tbl <- tibble::as_tibble(df, rownames = "patient_id")[, 1:26]
expr_mat <- as.matrix(df[, 26:ncol(df)])
expr_tbl <- tibble::as_tibble(t(expr_mat), rownames = "gene_id")

# Tidy up
cat("Tidying up\n")
# Pheno
names(pheno_tbl) <- names(pheno_tbl) |> 
    stringr::str_to_lower() |>
    stringr::str_replace_all("\\.| ", "_") |> 
    stringr::str_replace_all("_+", "_") |>
    stringr::str_remove("_$")
pheno_tbl <- pheno_tbl |> dplyr::rename(tidyselect::all_of(pheno_colnames_mapper))
pheno_tbl[["pfs_years"]] <- pheno_tbl[["pfs_years"]]/12
pheno_tbl[["os_years"]] <- pheno_tbl[["os_years"]]/12
pheno_tbl[["efs_years"]] <- pheno_tbl[["efs_years"]]/12
ipi_group_mapper <- c("low", "low", "intermediate", "intermediate", "high", "high")
pheno_tbl[["ipi_group"]] <- ipi_group_mapper[pheno_tbl[["ipi"]]+1]
# Add LAMIS score
pheno_tbl[["lamis_score"]] <- (expr_mat[, names(lamis_sig)] %*% 
    lamis_sig)[, 1]
pheno_tbl[["lamis_high"]] <- as.numeric(pheno_tbl[["lamis_score"]] >
    quantile(pheno_tbl[["lamis_score"]], 0.75))

# Assimilate expression and pheno data
res <- ensure_patients_match(expr_tbl, pheno_tbl)
expr_tbl <- res[["expr_tbl"]]

data <- Data$new(
    name = "Staiger et al. (2019)",
    directory = data_dir,
    cohort = ".",
    pivot_time_cutoff = pivot_time_cutoff,
    benchmark_col = benchmark_col,
    time_to_event_col = time_to_event_col,
    event_col = event_col,
    cohort_col = "cohort",
    imputer = mean_impute
)
data$pheno_tbl <- res[["pheno_tbl"]]
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