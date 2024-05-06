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
    split_index = 1:15,
    time_cutoffs = seq(1, 2, .25), # seq(1.5, 2, .25)
    hyperparams = list(family = "binomial", alpha = 1),
    response_type = "binary"
)

models <- list(
    # COX
    # vanilla
    cox = cox,
    cox_std = cox_std,
    # zerosum
    cox_zerosum = cox_zerosum,
    # LOGISTIC
    # vanilla
    logistic = logistic,
    logistic_std = logistic_std,
    # zerosum
    logistic_zerosum = logistic_zerosum
)