# Download, preprocess, store and split 562 DLBCL RNAseq bulks provided by Schmitz et al. (2018), 
# PMID: 29641966

# This script yields three files: two csv files with pheno and expression data, respectively, and one json 
# file holding info. Modify the names and directories for these files via the below global variables

library(patroklos)

set.seed(234)

data_dir <- "data/schmitz"
clean <- FALSE
only_with_survival_analyis <- TRUE
training_prop <- 0.66 
pivot_time_cutoff <- 2
time_to_event_col <- "pfs_years"
event_col <- "progression"
benchmark_col <- "ipi"
ipi_feat_cols <- c("age", "ann_arbor_stage", "ldh_ratio", "ecog_performance_status", 
    "n_extranodal_sites")
ipi_cutoffs <- c(60, 2, 1, 1, 1)
gl <- rep(">", 5)

expr_url <- "https://api.gdc.cancer.gov/data/894155a9-b039-4d50-966c-997b0e2efbc2"
expr_download_fname <- "expr.tsv"
pheno_url <- "https://api.gdc.cancer.gov/data/529be438-e42c-4725-a3f3-66f6fd42ffae"
pheno_download_fname <- "pheno.xlsx"
pheno_sheet_no <- 9

# Gene_ID column uses | character for three genes
expr_coltypes <- stringr::str_c("ccc", stringr::str_dup("d", 562))
pheno_colnames_mapper <- c(
    patient_id = "dbGaP submitted subject ID",
    progression = "Progression_Free Survival _PFS_ Status_ 0 No Progressoin_ 1 Progression",
    pfs_years = "Progression_Free Survival _PFS_ Time _yrs",
    n_extranodal_sites = "Number of Extranodal Sites"
)
expr_colnames_mapper <- c(gene_id = "Gene")

expr_fname <- file.path(data_dir, "expr.tsv")
pheno_fname <- file.path(data_dir, "pheno.xlsx")

if(!dir.exists(data_dir)){
    cat("Creating directory", data_dir, "\n")
    dir.create(data_dir)
}

# Download
if(!file.exists(expr_fname)){
    cat("Downloading expression data to", expr_fname, "\n")
    download.file(expr_url, expr_fname)
}
if(!file.exists(pheno_fname)){
    cat("Downloading pheno data to", pheno_fname, "\n")
    download.file(pheno_url, pheno_fname)
}
cat("Reading in data\n")
expr_tbl <- readr::read_tsv(expr_fname, col_types = expr_coltypes)
pheno_tbl <- readxl::read_excel(pheno_fname, sheet = pheno_sheet_no)

# Tidy up
cat("Tidying up\n")
# Expression
expr_tbl <- expr_tbl[, c(-2, -3)] # 3 columns with gene ids, only keep hgnc
expr_tbl <- expr_tbl |> dplyr::rename(tidyselect::all_of(expr_colnames_mapper))
# Pheno
pheno_tbl <- pheno_tbl |> dplyr::rename(tidyselect::all_of(pheno_colnames_mapper))
names(pheno_tbl) <- names(pheno_tbl) |> 
    stringr::str_to_lower() |>
    stringr::str_replace_all(" ", "_") |> 
    stringr::str_replace_all("_+", "_") |>
    stringr::str_remove("_$")
pheno_tbl[["ipi"]] <- ifelse(pheno_tbl[["ipi_range"]] <= 5, pheno_tbl[["ipi_range"]], NA)
if(only_with_survival_analyis){
    pheno_tbl <- pheno_tbl[pheno_tbl[["pfs_years"]] > 0 & !is.na(pheno_tbl[["pfs_years"]]), ]
}

# Assimilate expression and pheno data
res <- ensure_patients_match(expr_tbl, pheno_tbl)
expr_tbl <- res[["expr_tbl"]]
pheno_tbl <- res[["pheno_tbl"]]

data <- Data$new(
    name = "Schmitz et al. (2018)",
    directory = data_dir,
    train_prop = training_prop,
    pivot_time_cutoff = pivot_time_cutoff,
    benchmark_col = benchmark_col,
    time_to_event_col = time_to_event_col,
    event_col = event_col
)

pheno_tbl <- discretize_tbl_cols(
    tbl = pheno_tbl, 
    col_names = ipi_feat_cols,
    cutoffs = ipi_cutoffs,
    gl = gl
)

qc_preprocess(
    data = data,
    expr_tbl = expr_tbl,
    pheno_tbl = pheno_tbl
)

write_data_info(
    filename = file.path(data_dir, "info.json"),
    expr_tbl = expr_tbl,
    pheno_tbl = pheno_tbl,
    data = data
)

cat("Writing preprocessed data to", data_dir, "\n")
# readr::write_csv(pheno_tbl, file.path(data_dir, "pheno.csv"))
# readr::write_csv(expr_tbl, file.path(data_dir, "expr.csv"))
saveRDS(data, file.path(data_dir, "data.rds"))

if(clean){
    cat("Removing downloaded files\n")
    file.remove(expr_fname, pheno_fname)
}
