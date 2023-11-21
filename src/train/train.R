# A wrapper function to train models

train <- function(
    data_dir,
    model_name,
    store_model_as,
    expr_fname = "expr.csv",
    pheno_fname = "pheno.csv",
    use_existent_model = TRUE
){
    data <- read_data(
        data_dir,
        expr_fname = expr_fname,
        pheno_fname = pheno_fname
    )
    fit_model <- switch(
        "cox_lasso_zerosum" = cox_lasso_zerosum,
        "cox_lasso" = cox_lasso
    )
    if(file.exists(store_model_as)){
        fit <- readRDS(store_model_as)
    } else {
        fit <- fit_model(
            expr = data[["expr"]]
            pheno = tr[["pheno"]]
        )
    }
    return(fit)
}