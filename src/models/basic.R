# BASIC models (only genomic data)

# COX
# vanilla
cox = Model$new(
    name = "cox",
    directory = "cox/0-vanilla/zerosum",
    fitter = zeroSum::zeroSum,
    split_index = 1:15, # 1:20
    time_cutoffs = c(seq(1, 2.5, .25), Inf), # seq(1.5, 2, .25)
    hyperparams = list(family = "cox", alpha = 1, zeroSum = FALSE),
    response_type = "survival_censored"
)
cox_std = Model$new(
    name = "cox std",
    directory = "cox/0-vanilla/std",
    fitter = zeroSum::zeroSum,
    split_index = 1:15,
    time_cutoffs = c(seq(1, 2, .25), Inf),
    hyperparams = list(family = "cox", alpha = 1, zeroSum = FALSE,
        standardize = TRUE),
    response_type = "survival_censored"
)
# zerosum
cox_zerosum = Model$new(
    name = "cox zerosum",
    fitter = zeroSum::zeroSum,
    directory = "cox/1-zerosum",
    split_index = 1:15,
    time_cutoffs = c(seq(1, 2, .25), Inf), # seq(1.5, 2, .25)
    hyperparams = list(family = "cox", alpha = 1),
    response_type = "survival_censored"
)
# LOGISTIC
# vanilla
logistic = Model$new(
    name = "logistic",
    directory = "logistic/0-vanilla/zerosum",
    fitter = zeroSum::zeroSum,
    split_index = 1:15, # 1:20
    time_cutoffs = seq(1, 2, .25), # seq(1.5, 2, .25)
    hyperparams = list(family = "binomial", alpha = 1, zeroSum = FALSE),
    response_type = "binary"
)
logistic_std = Model$new(
    name = "logistic std",
    directory = "logistic/0-vanilla/std",
    fitter = zeroSum::zeroSum,
    split_index = 1:15,
    time_cutoffs = seq(1, 2, .25),
    hyperparams = list(family = "binomial", alpha = 1, zeroSum = FALSE,
        standardize = TRUE),
    response_type = "binary"
)
# zerosum
logistic_zerosum = Model$new(
    name = "logistic zerosum",
    directory = "logistic/1-zerosum",
    fitter = zeroSum::zeroSum,
    split_index = 1:10,
    time_cutoffs = seq(1, 2, .25), # seq(1.5, 2, .25)
    hyperparams = list(family = "binomial", alpha = 1),
    response_type = "binary"
)

# GAUSS
# vanilla
gauss = Model$new(
    name = "gauss",
    directory = "gauss/0-vanilla/zerosum",
    fitter = zeroSum::zeroSum,
    split_index = 1:10, # 1:20
    time_cutoffs = seq(1.5, 2, .25), # seq(1.5, 2, .25)
    hyperparams = list(family = "gaussian", alpha = 1, zeroSum = FALSE),
    response_type = "binary"
)
gauss_std = Model$new(
    name = "gauss std",
    directory = "gauss/0-vanilla/std",
    fitter = zeroSum::zeroSum,
    split_index = 1:10,
    time_cutoffs = seq(1.5, 2, .25),
    hyperparams = list(family = "gaussian", alpha = 1, zeroSum = FALSE,
        standardize = TRUE),
    response_type = "binary"
)
# zerosum
gauss_zerosum = Model$new(
    name = "gauss zerosum",
    fitter = zeroSum::zeroSum,
    directory = "gauss/1-zerosum",
    split_index = 1:10,
    time_cutoffs = seq(1.5, 2, .25), # seq(1.5, 2, .25)
    hyperparams = list(family = "gaussian", alpha = 1),
    response_type = "binary"
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
the_best <- list()
for (model in models) {
    if(!stringr::str_detect(model$name, "zerosum")) {
        the_best <- c(the_best, model$clone())
    }
}

for_reddy <- list()
for (i in seq_along(the_best)) {
    model <- the_best[[i]]$clone()
    model$time_cutoffs <- model$time_cutoffs + 0.5
    for_reddy <- c(for_reddy, model)
}
