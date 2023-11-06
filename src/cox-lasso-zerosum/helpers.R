# Some commonly used functions when fitting Cox proportional-hazards models
# with LASSO and zero-sum constraint

library(tidyverse)

read_data <- function(
    data_path,
    dir
){
    res <- list()
    for (expr_pheno in c("expr", "pheno")){
        full_path <- file.path(data_path, dir, str_c(expr_pheno, ".csv"))
        res[[expr_pheno]] <- read_csv(full_path)
    }
    return(res)
}

prepare_data <- function(
    expr_df,
    pheno_df,
    follow_up = FALSE
    ){
    keep_idx <- which(pheno_df$follow_up_yrs >= 2)
    x <- expr_df %>% 
        column_to_rownames(var = "Gene") %>% 
        as.matrix() %>% 
        t()
    y <- pheno_df %>%
        column_to_rownames(var = "patient_id") %>%
        select(
            pfs_yrs, 
            progression
            ) %>%
        as.matrix()
    if (!all((rownames(x) == rownames(y))))
        stop("Sample names in expression and pheno data do not match!")
    if(follow_up){
        cat("Removing patients with follow-up time <= 2 yrs.\n")
        cat("Number of patients before:", nrow(y), "\n")
        y <- y[keep_idx,]
        x <- x[keep_idx,]
        cat("Number of patients after removal:", nrow(y), "\n")
    }
    res <- list(
        "x" = x,
        "y" = y
    )
    return(res)
}
