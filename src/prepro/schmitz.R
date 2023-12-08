# Download, preprocess, store and split 562 DLBCL RNAseq bulks provided by Schmitz et al. (2018), 
# PMID: 29641966

# This script yields three files: two csv files with pheno and expression data, respectively, and one json 
# file holding info. Modify the names and directories for these files via the below global variables

library(lymphomaSurvivalPipeline)

data_dir <- "data/schmitz"
clean <- FALSE
only_with_survival_analyis <- TRUE
training_prop <- 0.66 
pfs_cut <- 2.

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
    pfs_years = "Progression_Free Survival _PFS_ Time _yrs"
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
data <- ensure_patients_match(expr_tbl, pheno_tbl)
expr_tbl <- data$expr_tbl
pheno_tbl <- data$pheno_tbl


data_spec <- DataSpec(
    name = "Schmitz et al. (2018)",
    directory = data_dir
)

qc_preprocess(
    expr_tbl = expr_tbl,
    pheno_tbl = pheno_tbl,
    data_spec = data_spec,
    check_default = TRUE
)

# Document
n_included_in_survival_analysis <- (pheno_tbl[["pfs_years"]] > 0) |> 
    sum(na.rm = TRUE)
n_high_risk <- (pheno_tbl[["pfs_years"]] < pfs_cut & pheno_tbl[["progression"]] == 1) |> 
    sum(na.rm = TRUE)
n_low_risk <- (pheno_tbl[["pfs_years"]] >= pfs_cut) |> sum(na.rm = TRUE)

info_list <- list(
    "publication" = list(
        "title" = "Genetics and Pathogenesis of Diffuse Large B-Cell Lymphoma",
        "author" = "Schmitz et al.",
        "year" = 2018,
        "doi"= "10.1056/NEJMoa1801445",
        "pubmed id" = 29641966
    ),
    "data" = list(
        "website" = "https://gdc.cancer.gov/about-data/publications/DLBCL-2018",
        "disease type" = "DLBCL",
        "number of samples" = nrow(pheno_tbl),
        "pheno data" = list(
            "included in survival analysis" =  n_included_in_survival_analysis,
            "pfs cutoff" = pfs_cut,
            "number high risk" = n_high_risk,
            "number low risk" = n_low_risk,
            "unknown" = n_included_in_survival_analysis - n_high_risk - n_low_risk
        ),
        "expression data" = list(
            "technology" = "bulk RNA-seq",
            "platform" = "Illumina HiSeq 2500|3000",
            "read length" = "100|150 paired-end",
            "number of genes" = nrow(expr_tbl),
            "gene symbols" = "HGNC",
            "primary processing" = "see Supplementary Appendix 1 @ https://api.gdc.cancer.gov/data/288619d2-a7b6-4ee3-aa27-ae2c77887b31, p. 6",
            "normalization" = "fpkm values in log2 scale"    
        )
    )
)

cat("Writing preprocessed data to", data_dir, "\n")
readr::write_csv(pheno_tbl, file.path(data_dir, "pheno.csv"))
readr::write_csv(expr_tbl, file.path(data_dir, "expr.csv"))
saveRDS(data_spec, file.path(data_dir, "data_spec.rds"))
jsonlite::write_json(info_list, file.path(data_dir, "info.json"), auto_unbox = TRUE, pretty = TRUE)

split_dataset(
    expr_tbl = expr_tbl,
    pheno_tbl = pheno_tbl,
    data_spec = data_spec,
    train_prop = .66,
    pfs_cut = pfs_cut,
    based_on_pfs_cut = TRUE
)

if(clean){
    cat("Removing downloaded files\n")
    file.remove(expr_fname, pheno_fname)
}