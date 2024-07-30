# BASIC models (only genomic data)

library(patroklos)

# COX
# vanilla
cox = Model$new(
    name = "cox",
    directory = "cox/0-vanilla/zerosum",
    fitter = ptk_zerosum,
    time_cutoffs = c(seq(1, 2.5, .25), Inf), # seq(1.5, 2, .25)
    val_error_fun = neg_prec_with_prev_greater(0.17),
    hyperparams = list(family = "cox", alpha = 1, zeroSum = FALSE, nFold = 1000),
    continuous_output = TRUE
)
cox_std = Model$new(
    name = "cox std",
    directory = "cox/0-vanilla/std",
    fitter = ptk_zerosum,
    val_error_fun = neg_prec_with_prev_greater(0.17),
    time_cutoffs = c(seq(1, 2.5, .25), Inf),
    hyperparams = list(family = "cox", alpha = 1, zeroSum = FALSE,
        standardize = TRUE, nFold = 1000),
    continuous_output = TRUE
)
# zerosum
cox_zerosum = Model$new(
    name = "cox zerosum",
    fitter = ptk_zerosum,
    directory = "cox/1-zerosum",
    time_cutoffs = c(seq(1.5, 2., .25), Inf), # seq(1.5, 2, .25)
    val_error_fun = neg_prec_with_prev_greater(0.17),
    hyperparams = list(family = "cox", alpha = 1, nFold = 1000),
    continuous_output = TRUE
)
# LOGISTIC
# vanilla
log = Model$new(
    name = "log",
    directory = "log/0-vanilla/zerosum",
    fitter = ptk_zerosum,
    time_cutoffs = seq(1, 2.5, .25), # seq(1.5, 2, .25)
    val_error_fun = neg_prec_with_prev_greater(0.17),
    hyperparams = list(family = "binomial", alpha = 1, zeroSum = FALSE, 
        nFold = 1000),
    continuous_output = TRUE
)
log_std = Model$new(
    name = "log std",
    directory = "log/0-vanilla/std",
    fitter = ptk_zerosum,
    time_cutoffs = seq(1, 2.5, .25),
    val_error_fun = neg_prec_with_prev_greater(0.17),
    hyperparams = list(family = "binomial", alpha = 1, zeroSum = FALSE,
        standardize = TRUE, nFold = 1000),
    continuous_output = TRUE
)
# zerosum
log_zerosum = Model$new(
    name = "log zerosum",
    directory = "log/1-zerosum",
    fitter = ptk_zerosum,
    time_cutoffs = seq(1.0, 2, .25), # seq(1.5, 2, .25)
    val_error_fun = neg_prec_with_prev_greater(0.17),
    hyperparams = list(family = "binomial", alpha = 1, nFold = 1000),
    continuous_output = TRUE
)

# GAUSS
# vanilla
gauss = Model$new(
    name = "gauss",
    directory = "gauss/0-vanilla/zerosum",
    fitter = ptk_zerosum,
    time_cutoffs = seq(1, 2.5, .25), # seq(1.5, 2, .25)
    val_error_fun = neg_prec_with_prev_greater(0.17),
    hyperparams = list(family = "gaussian", alpha = 1, zeroSum = FALSE, nFold = 1000),
    continuous_output = TRUE
)
gauss_std = Model$new(
    name = "gauss std",
    directory = "gauss/0-vanilla/std",
    fitter = ptk_zerosum,
    time_cutoffs = seq(1, 2.5, .25),
    val_error_fun = neg_prec_with_prev_greater(0.17),
    hyperparams = list(family = "gaussian", alpha = 1, zeroSum = FALSE,
        standardize = TRUE, nFold = 1000),
    continuous_output = TRUE
)
# zerosum
gauss_zerosum = Model$new(
    name = "gauss zerosum",
    fitter = ptk_zerosum,
    directory = "gauss/1-zerosum",
    time_cutoffs = seq(1.5, 2, .25), # seq(1.5, 2, .25)
    val_error_fun = neg_prec_with_prev_greater(0.17),
    hyperparams = list(family = "gaussian", alpha = 1),
    continuous_output = TRUE
)

models <- list(
    cox,
    cox_std,
    cox_zerosum,
    log,
    log_std,
    log_zerosum,
    gauss,
    gauss_std,
    gauss_zerosum
)

ridge_models <- list()
for (i in seq_along(models)) {
    model <- models[[i]]$clone()
    model$name <- paste0(model$name, " ridge")
    model$directory <- file.path(model$directory, "ridge")
    model$hyperparams$alpha <- 0.1
    ridge_models[[i]] <- model
}
models <- c(models, ridge_models)

# Projection on IPI
ipi <- Model$new(
    name = "ipi",
    directory = "ipi",
    fitter = projection_on_feature,
    time_cutoffs = 2,
    val_error_fun = neg_prec_with_prev_greater(0.17),
    hyperparams = list(feature = "ipi"),
    include_from_continuous_pheno = "ipi",
    include_from_discrete_pheno = NULL,
    include_expr = FALSE,
    enable_imputation = FALSE
)
models <- c(models, ipi)

# Model for new data sets where you cannot try out everything
general <- list()
for (model in models) {
    if(!stringr::str_detect(model$name, "zerosum")) {
       general <- c(general, model$clone())
    }
}
names(general) <- sapply(general, function(x) x$name)