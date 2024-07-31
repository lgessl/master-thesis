# Models trained on Staiger et al. (2018)

# Basic (only expression data)

source("src/models/basic.R")

basic <- general

# Early and late integration

include_from_discrete_pheno <- c("gender", "ipi_group", "gene_expression_subgroup",
    "exbm", "bm", "lamis_high")

ipi_group <- Model$new(
    name = "cox-cox with IPI group, rest",
    fitter = greedy_nestor,
    directory = "cox/late-int/cox-cox-ipi-group-rest",
    time_cutoffs = Inf,
    val_error_fun = neg_prec_with_prev_greater(0.17),
    hyperparams = list(
        model1 = basic[["cox"]],
        fitter2 = ptk_zerosum,
        hyperparams2 = list(
            family = "cox",
            alpha = 1,
            zeroSum = FALSE,
            nFold = 1000,
            standardize = TRUE,
            exclude_pheno_from_lasso = FALSE
        )
    ),
    include_from_discrete_pheno = include_from_discrete_pheno,
    include_from_continuous_pheno = c("lamis_score"),
    include_expr = TRUE,
    combine_n_max_categorical_features = 1:3,
    combined_feature_min_positive_ratio = 0.05,
    continuous_output = TRUE
)

ipi_disc <- ipi_group$clone()
ipi_disc$name <- "cox-cox with disc IPI, rest"
ipi_disc$directory <- "cox/late-int/cox-cox-disc-ipi-rest"
ifdp <- ipi_disc$include_from_discrete_pheno
ifdp <- ifdp[ifdp != "ipi_group"]
ipi_disc$include_from_discrete_pheno <- c(ifdp, "age>60", "ldh_ratio>1", 
    "ecog_performance_status>1", "n_extranodal_sites>1", "ann_arbor_stage>2")

ipi_cont <- ipi_group$clone()
ipi_cont$name <- "cox-cox with IPI score cont, rest"
ipi_cont$directory <- "cox/late-int/cox-cox-ipi-score-cont-rest"
ifdp <- ipi_cont$include_from_discrete_pheno
ifdp <- ifdp[ifdp != "ipi_group"]
ipi_cont$include_from_discrete_pheno <- ifdp
ipi_cont$include_from_continuous_pheno <- c("ipi", "lamis_score")

ipi_all <- ipi_group$clone()
ipi_all$name <- "cox-cox with all IPI"
ipi_all$directory <- "cox/late-int/cox-cox-all-ipi"
ipi_all$include_from_discrete_pheno <- c(ipi_group$include_from_discrete_pheno, 
    "age>60", "ldh_ratio>1", "ecog_performance_status>1", "n_extranodal_sites>1", 
    "ann_arbor_stage>2")
ipi_all$include_from_continuous_pheno <- c("ipi", "lamis_score")

ei_li <- list(ipi_group, ipi_disc, ipi_cont, ipi_all)

# Early integration with Cox
for (model in ei_li[1:4]) {
    ei_cox <- model$clone()
    ei_cox$name <- stringr::str_replace(model$name, "-cox", " ei")
    dir <- stringr::str_replace(model$directory, "cox-cox", "cox-ei")
    ei_cox$directory <- stringr::str_replace(dir, "late-int", "early-int")
    ei_cox$fitter <- ptk_zerosum
    ei_cox$hyperparams <- list(family = "cox", alpha = 1, zeroSum = FALSE,
        standardize = TRUE, exclude_pheno_from_lasso = FALSE, nFold = 1000)
    ei_li <- c(ei_li, ei_cox)
}

# Late integration with rf, logistic as late model
for (model in ei_li[1:4]) {
    rf <- model$clone()
    rf$name <- stringr::str_replace(model$name, "cox-cox", "cox-rf")
    rf$directory <- stringr::str_replace(model$directory, "cox-cox", "cox-rf")
    rf$hyperparams[["fitter2"]] <- hypertune(ptk_ranger)
    rf$hyperparams[["hyperparams2"]] <- list(
        num.trees = 600,
        min.node.size = 1:10, 
        mtry = seq(0.8, 1.2, 0.04),
        rel_mtry = TRUE,
        classification = TRUE,
        skip_on_invalid_input = TRUE
    )
    rf$continuous_output <- FALSE
    log <- model$clone()
    log$name <- stringr::str_replace(model$name, "cox-cox", "cox-log")
    log$directory <- stringr::str_replace(model$directory, "cox-cox", "cox-log")
    log$hyperparams[["fitter2"]] <- ptk_zerosum
    log$hyperparams[["hyperparams2"]] <- list(family = "binomial", alpha = 1, 
        zeroSum = FALSE, standardize = TRUE, exclude_pheno_from_lasso = FALSE, 
        nFold = 1000)
    ei_li <- c(ei_li, rf, log)
}

# No expression
for (model in ei_li) {
    if (stringr::str_detect(model$name, "cox ei")) {
        # Cox
        no_expr_cox <- model$clone()
        no_expr_cox$name <- paste(model$name, "no expr")
        no_expr_cox$directory <- paste0(model$directory, "-no-expr")
        no_expr_cox$include_expr <- FALSE
        # log
        log <- no_expr_cox$clone()
        log$name <- stringr::str_replace(no_expr_cox$name, "cox", "log")
        log$directory <- stringr::str_replace_all(no_expr_cox$directory, "cox", "log")
        log$hyperparams[["family"]] <- "binomial"
        log$time_cutoffs <- 2
        # Gauss
        gauss <- no_expr_cox$clone()
        gauss$name <- stringr::str_replace(no_expr_cox$name, "cox", "gauss")
        gauss$directory <- stringr::str_replace_all(no_expr_cox$directory, "cox", "gauss")
        gauss$hyperparams[["family"]] <- "gaussian"
        gauss$time_cutoffs <- 2
        # rf
        no_expr_rf <- no_expr_cox$clone()
        no_expr_rf$name <- stringr::str_replace(no_expr_rf$name, "cox ei", "rf ei")
        dir <- stringr::str_replace(no_expr_rf$directory, "cox-ei", "rf-ei")
        no_expr_rf$directory <- stringr::str_replace(dir, "cox", "rf")
        no_expr_rf$fitter <- hypertune(ptk_ranger, select = TRUE)
        no_expr_rf$hyperparams <- list(
            num.trees = 600,
            min.node.size = 1:10, 
            mtry = seq(0.8, 1.2, 0.04),
            rel_mtry = TRUE,
            classification = TRUE,
            skip_on_invalid_input = TRUE
        )
        no_expr_rf$continuous_output <- TRUE
        ei_li <- c(ei_li, no_expr_cox, log, gauss, no_expr_rf)
    }
}

# Put them all together

models <- c(basic, ei_li)
names(models) <- sapply(models, function(x) x$name)
prepend_to_directory(models, "models/lamis_test2")