# Models trained on Staiger et al. (2018)

# Basic (only expression data)

source("src/models/basic.R")

basic <- general

# Early and late integration

include_from_discrete_pheno <- c("gender", "ipi_group", "gene_expression_subgroup",
    "exbm", "bm", "lamis_high")

ipi_group <- Model$new(
    name = "cox-(cv)cox pcv comb 4 with IPI group, all",
    fitter = nested_pseudo_cv,
    directory = "cox/2-late-int/cox-cvcox-pcv-comb-4-ipi-group-all",
    split_index = 1:5,
    time_cutoffs = Inf,
    hyperparams = list(
        fitter1 = ptk_zerosum,
        fitter2 = ptk_zerosum,
        hyperparams1 = list(
            family = "cox",
            alpha = 1,
            zeroSum = FALSE,
            nFold = 10,
            standardize = TRUE
        ),
        hyperparams2 = list(
            family = "cox",
            alpha = 1,
            zeroSum = FALSE,
            nFold = 10,
            standardize = TRUE,
            exclude_pheno_from_lasso = FALSE
        )
    ),
    include_from_discrete_pheno = include_from_discrete_pheno,
    include_from_continuous_pheno = c("lamis_score"),
    include_expr = TRUE,
    combine_n_max_categorical_features = 4,
    combined_feature_min_positive_ratio = 0.05,
    continuous_output = TRUE
)

ipi_disc <- ipi_group$clone()
ipi_disc$name <- "cox-(cv)cox pcv comb 4 with disc IPI, all"
ipi_disc$directory <- "cox/2-late-int/cox-cvcox-pcv-comb-4-disc-ipi-all"
ifdp <- ipi_disc$include_from_discrete_pheno
ifdp <- ifdp[ifdp != "ipi_group"]
ipi_disc$include_from_discrete_pheno <- c(ifdp, "age>60", "ldh_ratio>1", 
    "ecog_performance_status>1", "n_extranodal_sites>1", "ann_arbor_stage>2")

ipi_cont <- ipi_group$clone()
ipi_cont$name <- "cox-(cv)cox pcv comb 4 with IPI score cont, all"
ipi_cont$directory <- "cox/2-late-int/cox-cvcox-pcv-comb-4-ipi-score-cont-all"
ifdp <- ipi_cont$include_from_discrete_pheno
ifdp <- ifdp[ifdp != "ipi_group"]
ipi_cont$include_from_discrete_pheno <- ifdp
ipi_cont$include_from_continuous_pheno <- c("ipi", "lamis_score")

ipi_all <- ipi_group$clone()
ipi_all$name <- "cox-(cv)cox pcv comb 4 with all IPI"
ipi_all$directory <- "cox/2-late-int/cox-cvcox-pcv-comb-4-all-ipi"
ipi_all$include_from_discrete_pheno <- c(ipi_group$include_from_discrete_pheno, 
    "age>60", "ldh_ratio>1", "ecog_performance_status>1", "n_extranodal_sites>1", 
    "ann_arbor_stage>2")
ipi_all$include_from_continuous_pheno <- c("ipi")

ei_li <- list(ipi_group, ipi_disc, ipi_cont, ipi_all)

# Early integration with Cox, logistic
for(model in ei_li[1:4]){
    model_ei <- model$clone()
    model_ei$name <- stringr::str_replace(model$name, "-\\(cv\\)cox pcv", " ei")
    dir <- stringr::str_replace(model$directory, "cvcox-pcv", "ei")
    model_ei$directory <- stringr::str_replace(dir, "2-late-int", "3-early-int")
    model_ei$fitter <- ptk_zerosum
    model_ei$hyperparams <- list(family = "cox", alpha = 1, zeroSum = FALSE,
        standardize = TRUE, exclude_pheno_from_lasso = FALSE)
    ei_log <- model$clone()
    ei_log$name <- stringr::str_replace(model$name, "cox-\\(cv\\)cox pcv", "log ei")
    dir <- stringr::str_replace(model$directory, "cox-cvcox-pcv", "log-ei")
    dir <- stringr::str_replace(dir, "cox", "logistic")
    ei_log$directory <- stringr::str_replace(dir, "2-late-int", "3-early-int")
    ei_log$fitter <- ptk_zerosum
    ei_log$hyperparams <- list(family = "binomial", alpha = 1, zeroSum = FALSE,
        standardize = TRUE, exclude_pheno_from_lasso = FALSE)
    ei_li <- c(ei_li, model_ei, ei_log)
}

# Late integration with rf, logistic as late model
for (model in ei_li[1:4]) {
    rf <- model$clone()
    rf$name <- stringr::str_replace(model$name, "\\(cv\\)cox", "rf")
    rf$directory <- stringr::str_replace(model$directory, "cvcox", "rf")
    rf$hyperparams[["fitter2"]] <- hypertune(ptk_ranger, error = "error_rate")
    rf$hyperparams[["hyperparams2"]] <- list(
        num.trees = 1000,
        min.node.size = 1:10, 
        mtry = seq(0.8, 1.2, 0.04),
        rel_mtry = TRUE,
        classification = TRUE,
        skip_on_invalid_input = TRUE
    )
    rf$continuous_output <- FALSE
    log <- model$clone()
    log$name <- stringr::str_replace(model$name, "\\(cv\\)cox", "log")
    dir <- stringr::str_replace(model$directory, "cvcox", "log")
    log$directory <- stringr::str_replace(dir, "cox", "logistic")
    log$hyperparams[["fitter2"]] <- ptk_zerosum
    log$hyperparams[["hyperparams2"]] <- list(family = "binomial", alpha = 1, 
        zeroSum = FALSE, standardize = TRUE, exclude_pheno_from_lasso = FALSE)
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
        no_expr_rf <- no_expr_cox$clone()
        no_expr_rf$name <- stringr::str_replace(no_expr_rf$name, "cox ei", "rf ei")
        dir <- stringr::str_replace(no_expr_rf$directory, "cox-ei", "rf-ei")
        # rf
        no_expr_rf$directory <- stringr::str_replace(dir, "cox", "rf")
        no_expr_rf$fitter <- hypertune(ptk_ranger, error = "error_rate")
        no_expr_rf$hyperparams <- list(
            num.trees = 1000,
            min.node.size = 1:10, 
            mtry = seq(0.8, 1.2, 0.04),
            rel_mtry = TRUE,
            classification = TRUE,
            skip_on_invalid_input = TRUE
        )
        no_expr_rf$continuous_output <- FALSE
        ei_li <- c(ei_li, no_expr_cox, no_expr_rf)
    }
    # Logistic
    if (stringr::str_detect(model$name, "log ei")) {
        no_expr_log <- model$clone()
        no_expr_log$name <- paste(model$name, "no expr")
        no_expr_log$directory <- paste0(model$directory, "-no-expr")
        no_expr_log$include_expr <- FALSE
        ei_li <- c(ei_li, no_expr_log)
    }
}

# The same with 1, 2, 3 n_max combined categorical features

for (model in ei_li) {
    for (i in 1:3) {
        comb <- model$clone()
        comb$name <- stringr::str_replace(model$name, "comb 4", paste("comb", i))
        comb$directory <- stringr::str_replace(model$directory, "comb-4", 
            paste0("comb-", i))
        comb$combine_n_max_categorical_features <- i
        ei_li <- c(ei_li, comb)
    }
}

# Put them all together

models <- c(basic, ei_li)
names(models) <- sapply(models, function(x) x$name)