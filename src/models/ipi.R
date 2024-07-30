# Define the IPI as a Model R6 class

library(patroklos)

ipi <- Model$new(
    name = "ipi",
    directory = "models/ipi",
    fitter = ptk_zerosum,
    time_cutoffs = 2,
    val_error_fun = neg_prec_with_prev_greater(0.17),
    hyperparams = list(family = "gaussian", alpha = 1, lambda = 0, zeroSum = FALSE),
    include_from_continuous_pheno = "ipi",
    include_from_discrete_pheno = NULL,
    include_expr = FALSE,
    enable_imputation = FALSE
)
data <- readRDS("data/lamis_test2/data.rds")
data$cohort <- "train"
ipi$fit(data)
ipi$fit_obj$coef[[1]][, 1] <- c(0, 1)
ipi$fit_obj$val_predict[, 1] <- NA
saveRDS(ipi, "models/ipi/model.rds")
