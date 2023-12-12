# General list of ModelSpec objects you can source into any script training models on a 
# certain data set

model_spec_list <- list(
    cox_lasso_zerosum = ModelSpec(
        name = "Cox LASSO zeroSum",
        fitter = zeroSum::zeroSum,
        optional_fitter_args = list(family = "cox", alpha = 1),
        response_type = "survival_censored",
        save_dir = "cox-lasso-zerosum"
    ),
    binomial_lasso_zerosum = ModelSpec(
        name = "Binomial LASSO zeroSum",
        fitter = zeroSum::zeroSum,
        optional_fitter_args = list(family = "binomial", alpha = 1),
        response_type = "binary",
        save_dir = "binomial-lasso-zerosum"
    ),
    cox_lasso = ModelSpec(
        name = "Cox LASSO",
        fitter = zeroSum::zeroSum,
        optional_fitter_args = list(family = "cox", alpha = 1, zeroSum = FALSE),
        response_type = "survival_censored",
        save_dir = "cox-lasso"
    ),
    binomial_lasso = ModelSpec(
        name = "Binomial LASSO",
        fitter = zeroSum::zeroSum,
        optional_fitter_args = list(family = "binomial", alpha = 1, zeroSum = FALSE),
        response_type = "binary",
        save_dir = "binomial-lasso"
    )
)