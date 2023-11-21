# Some commonly used functions when fitting Cox proportional-hazards models
# with LASSO and zero-sum constraint

import("dplyr") # for %>%
export("read_data", "prepare_data")

read_data <- function(
    data_dir,
    expr_fname = "expr.csv",
    pheno_fname = "pheno.csv"
){
    fnames = c(expr_fname, pheno_fname)
    res <- list("expr" = NULL, "pheno" = NULL)
    for (i in 1:length(fnames)){
        full_path <- file.path(data_dir, fnames[i])
        res[[i]] <- readr::read_csv(full_path)
    }
    return(res)
}

prepare_data <- function(
    expr_df,
    pheno_df,
    with_follow_up = FALSE,
    pfs_cutoff = 2.,
    with_ipi = FALSE
    ){
    # Indices of samples we might want to remove
    no_follow_up_idx <- pheno_df$follow_up_yrs < pfs_cutoff & (pheno_df$progression == 0)
    ipi_na_idx <- pheno_df$ipi_group |> is.na()

    x <- expr_df %>% 
        tibble::column_to_rownames(var = "Gene") %>% 
        as.matrix() %>% 
        t()
    y <- pheno_df %>%
        tibble::column_to_rownames(var = "patient_id") %>%
        dplyr::select(
            pfs_yrs, 
            progression,
            ipi_group
            ) %>%
        as.matrix()

    if (!all((rownames(x) == rownames(y)))){
        stop("Sample names in expression and pheno data do not match!")
    }

    # Removals
    # Prepare for loop
    rm_what <- c(with_follow_up, with_ipi)
    rm <- logical(nrow(y))
    rm_bool <- list(no_follow_up_idx, ipi_na_idx)
    info <- c(
        stringr::str_c("Removing patients censored at less than ", pfs_cutoff, " years"),
        "Removing patients with IPI group not available"
    )
    if(sum(rm_what) > 0){
        cat("Removing samples with incomplete data\n")
        cat("Starting with", sum(!rm), "samples\n")
    }
    for(i in 1:length(rm_what)){
        if(rm_what[i]){
            cat(info[i], "\n")
            rm <- rm | rm_bool[[i]]  
            cat(sum(!rm), "samples remaining\n")
        }    
    }
    x <- x[!rm,]
    y <- y[!rm,]

    res <- list(
        "x" = x,
        "y" = y
    )
    return(res)
}
