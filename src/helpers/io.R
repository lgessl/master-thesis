# Some commonly used functions when fitting Cox proportional-hazards models
# with LASSO and zero-sum constraint

import("dplyr") # for %>%
export("read_data", "prepare_data")

read_data <- function(
    data_path,
    dir
){
    res <- list()
    for (expr_pheno in c("expr", "pheno")){
        full_path <- file.path(data_path, dir, stringr::str_c(expr_pheno, ".csv"))
        res[[expr_pheno]] <- readr::read_csv(full_path)
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
    rm <- !logical(nrow(y))
    for(i in 1:length(rm))
    rm_bool <- c(with_follow_up, with_ipi)
    rm_idx <- list(no_follow_up_idx, ipi_na_idx)
    info <- c(
        stringr::str_c("Removing patients censored at less than ", pfs_cutoff, " years.\n"),
        "Removing patients with IPI group not available.\n"
    )
    for(i in 1:length(rm_bool)){
        if(rm_bool[i]){
            cat(info[i])
            cat("Number of patients before removal:", nrow(y), "\n")
            y <- y[-rm_idx[[i]],]
            x <- x[-rm_idx[[i]],]
            cat("Number of patients after removal:", nrow(y), "\n")
            if(i < length(rm_bool)) cat("\n")
        }
    }

    res <- list(
        "x" = x,
        "y" = y
    )
    return(res)
}
