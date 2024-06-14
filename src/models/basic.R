# BASIC models (only genomic data)

# COX
# vanilla
cox = Model$new(
    name = "cox",
    directory = "cox/0-vanilla/zerosum",
    fitter = ptk_zerosum,
    split_index = 1:15, # 1:20
    time_cutoffs = c(seq(1, 2.5, .25), Inf), # seq(1.5, 2, .25)
    hyperparams = list(family = "cox", alpha = 1, zeroSum = FALSE),
    continuous_output = TRUE
)
cox_std = Model$new(
    name = "cox std",
    directory = "cox/0-vanilla/std",
    fitter = ptk_zerosum,
    split_index = 1:15,
    time_cutoffs = c(seq(1, 2.5, .25), Inf),
    hyperparams = list(family = "cox", alpha = 1, zeroSum = FALSE,
        standardize = TRUE),
    continuous_output = TRUE
)
# zerosum
cox_zerosum = Model$new(
    name = "cox zerosum",
    fitter = ptk_zerosum,
    directory = "cox/1-zerosum",
    split_index = 1:15,
    time_cutoffs = c(seq(1.5, 2., .25), Inf), # seq(1.5, 2, .25)
    hyperparams = list(family = "cox", alpha = 1),
    continuous_output = TRUE
)
# LOGISTIC
# vanilla
logistic = Model$new(
    name = "logistic",
    directory = "logistic/0-vanilla/zerosum",
    fitter = ptk_zerosum,
    split_index = 1:15, # 1:20
    time_cutoffs = seq(1, 2.5, .25), # seq(1.5, 2, .25)
    hyperparams = list(family = "binomial", alpha = 1, zeroSum = FALSE),
    continuous_output = TRUE
)
logistic_std = Model$new(
    name = "logistic std",
    directory = "logistic/0-vanilla/std",
    fitter = ptk_zerosum,
    split_index = 1:15,
    time_cutoffs = seq(1, 2.5, .25),
    hyperparams = list(family = "binomial", alpha = 1, zeroSum = FALSE,
        standardize = TRUE),
    continuous_output = TRUE
)
# zerosum
logistic_zerosum = Model$new(
    name = "logistic zerosum",
    directory = "logistic/1-zerosum",
    fitter = ptk_zerosum,
    split_index = 1:10,
    time_cutoffs = seq(1.5, 2, .25), # seq(1.5, 2, .25)
    hyperparams = list(family = "binomial", alpha = 1),
    continuous_output = TRUE
)

# GAUSS
# vanilla
gauss = Model$new(
    name = "gauss",
    directory = "gauss/0-vanilla/zerosum",
    fitter = ptk_zerosum,
    split_index = 1:10, # 1:20
    time_cutoffs = seq(1, 2.5, .25), # seq(1.5, 2, .25)
    hyperparams = list(family = "gaussian", alpha = 1, zeroSum = FALSE),
    continuous_output = TRUE
)
gauss_std = Model$new(
    name = "gauss std",
    directory = "gauss/0-vanilla/std",
    fitter = ptk_zerosum,
    split_index = 1:10,
    time_cutoffs = seq(1, 2.5, .25),
    hyperparams = list(family = "gaussian", alpha = 1, zeroSum = FALSE,
        standardize = TRUE),
    continuous_output = TRUE
)
# zerosum
gauss_zerosum = Model$new(
    name = "gauss zerosum",
    fitter = ptk_zerosum,
    directory = "gauss/1-zerosum",
    split_index = 1:10,
    time_cutoffs = seq(1.5, 2, .25), # seq(1.5, 2, .25)
    hyperparams = list(family = "gaussian", alpha = 1),
    continuous_output = TRUE
)

models <- list(
    cox,
    cox_std,
    cox_zerosum,
    logistic,
    logistic_std,
    logistic_zerosum,
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

# Model for new data sets where you cannot try out everything
general <- list()
for (model in models) {
    if(!stringr::str_detect(model$name, "zerosum")) {
       general <- c(general, model$clone())
    }
}