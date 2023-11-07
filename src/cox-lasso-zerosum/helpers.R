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
    follow_up = FALSE
    ){
    remove_idx <- which(pheno_df$follow_up_yrs <= 2 & (pheno_df$progression == 0))
    x <- expr_df %>% 
        tibble::column_to_rownames(var = "Gene") %>% 
        as.matrix() %>% 
        t()
    y <- pheno_df %>%
        tibble::column_to_rownames(var = "patient_id") %>%
        dplyr::select(
            pfs_yrs, 
            progression
            ) %>%
        as.matrix()
    if (!all((rownames(x) == rownames(y))))
        stop("Sample names in expression and pheno data do not match!")
    if(follow_up){
        cat("Removing patients censored at less than 2 years.\n")
        cat("Number of patients before:", nrow(y), "\n")
        y <- y[-remove_idx,]
        x <- x[-remove_idx,]
        cat("Number of patients after removal:", nrow(y), "\n")
    }
    res <- list(
        "x" = x,
        "y" = y
    )
    return(res)
}
