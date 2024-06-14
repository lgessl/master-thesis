# Models trained on Reddy et al. (2017)

# Basic (only expression data)

source("src/models/basic.R")

basic <- general
for(i in seq_along(basic)) {
    time_cutoffs <- basic[[i]]$time_cutoffs + 0.5
    time_cutoffs <- unique(c(time_cutoffs, 2.75, 3, 3.25, 3.5))
    basic[[i]]$time_cutoffs <- sort(time_cutoffs)
}

# Early and late integration

include_from_discrete_pheno <- c("gender", "ipi_group", "b_symptoms_at_diagnosis", 
    "response_to_initial_therapy", "testicular_involvement", "cns_involvement",
    "cns_relapse", "myc_high_expr", "bcl2_high_expr", "bcl6_high_expr", 
    "myc_translocation_seq", "bcl2_translocation_seq", "bcl6_translocation_seq",
    "gene_expression_subgroup")

ipi_group <- Model$new(
    name = "gauss-log pcv comb 4 with IPI group, all",
    fitter = nested_pseudo_cv,
    directory = "gauss/2-late-int/gauss-log-pcv-comb-4-ipi-group-all",
    split_index = 1:5,
    time_cutoffs = c(2.5), # Needs tuning! Assess basic models first!
    hyperparams = list(
        fitter1 = ptk_zerosum,
        fitter2 = ptk_zerosum,
        hyperparams1 = list(
            family = "gaussian",
            alpha = 1,
            zeroSum = FALSE,
            nFold = 10,
            standardize = TRUE
        ),
        hyperparams2 = list(
            family = "binomial",
            alpha = 1,
            zeroSum = FALSE,
            nFold = 10,
            standardize = TRUE,
            exclude_pheno_from_lasso = FALSE
        )
    ),
    include_from_discrete_pheno = include_from_discrete_pheno,
    include_from_continuous_pheno = NULL,
    include_expr = TRUE,
    combine_n_max_categorical_features = 4,
    combined_feature_min_positive_ratio = 0.05,
    continuous_output = TRUE
)

ipi_disc <- ipi_group$clone()
ipi_disc$name <- "gauss-log pcv comb 4 with disc IPI, all"
ipi_disc$directory <- "gauss/2-late-int/gauss-log-pcv-comb-4-disc-ipi-all"
ifdp <- ipi_disc$include_from_discrete_pheno
ifdp <- ifdp[ifdp != "ipi_group"]
ipi_disc$include_from_discrete_pheno <- c(ifdp, "age>60", "ldh_ratio>1", 
    "ecog_performance_status>1", "n_extranodal_sites>1", "ann_arbor_stage>2")

ipi_cont <- ipi_group$clone()
ipi_cont$name <- "gauss-log pcv comb 4 with IPI score cont, all"
ipi_cont$directory <- "gauss/2-late-int/gauss-log-pcv-comb-4-ipi-score-cont-all"
ifdp <- ipi_cont$include_from_discrete_pheno
ifdp <- ifdp[ifdp != "ipi_group"]
ipi_cont$include_from_discrete_pheno <- ifdp
ipi_cont$include_from_continuous_pheno <- c("ipi")

ipi_all <- ipi_group$clone()
ipi_all$name <- "gauss-log pcv comb 4 with all IPI"
ipi_all$directory <- "gauss/2-late-int/gauss-log-pcv-comb-4-all-ipi"
ipi_all$include_from_discrete_pheno <- c(ipi_group$include_from_discrete_pheno, 
    "age>60", "ldh_ratio>1", "ecog_performance_status>1", "n_extranodal_sites>1", 
    "ann_arbor_stage>2")
ipi_all$include_from_continuous_pheno <- c("ipi")

ei_li <- list(ipi_group, ipi_disc, ipi_cont, ipi_all)

# Early integration with gauss, cox
for(model in ei_li[1:4]){
    gauss <- model$clone()
    gauss$name <- stringr::str_replace(model$name, "-log pcv", " ei")
    dir <- stringr::str_replace(model$directory, "log-pcv", "ei")
    gauss$directory <- stringr::str_replace(dir, "2-late-int", "3-early-int")
    gauss$fitter <- ptk_zerosum
    gauss$hyperparams <- list(family = "gaussian", alpha = 1, zeroSum = FALSE,
        standardize = TRUE, exclude_pheno_from_lasso = FALSE)
    cox <- gauss$clone()
    cox$name <- stringr::str_replace(gauss$name, "gauss", "cox")
    cox$directory <- stringr::str_replace_all(gauss$directory, "gauss", "cox")
    cox$hyperparams[["family"]] <- "cox"

    ei_li <- c(ei_li, gauss, cox)
}

# Late integration with rf, cox
for (model in ei_li[1:4]) {
    rf <- model$clone()
    rf$name <- stringr::str_replace(model$name, "log", "rf")
    rf$directory <- stringr::str_replace(model$directory, "log", "rf")
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
    cox <- model$clone()
    cox$name <- stringr::str_replace(model$name, "log", "cox")
    cox$directory <- stringr::str_replace(model$directory, "log", "cox")
    cox$hyperparams[["hyperparams2"]][["family"]] <- "cox"
    ei_li <- c(ei_li, rf, cox)
}

# No expression for cox, logistic, rf
for (model in ei_li) {
    if (stringr::str_detect(model$name, "cox ei")) {
        cox <- model$clone()
        cox$name <- paste(model$name, "no expr")
        cox$directory <- paste0(model$directory, "-no-expr")
        cox$include_expr <- FALSE
        log <- cox$clone()
        log$name <- stringr::str_replace(cox$name, "cox", "log")
        log$directory <- stringr::str_replace_all(cox$directory, "cox", "log")
        log$hyperparams[["family"]] <- "binomial"
        rf <- cox$clone()
        rf$name <- stringr::str_replace(rf$name, "cox ei", "rf ei")
        rf$directory <- stringr::str_replace_all(cox$directory, "cox", "rf")
        rf$fitter <- hypertune(ptk_ranger, error = "error_rate")
        rf$hyperparams <- list(
            num.trees = 1000,
            min.node.size = 1:10, 
            mtry = seq(0.8, 1.2, 0.04),
            rel_mtry = TRUE,
            classification = TRUE,
            skip_on_invalid_input = TRUE
        )
        rf$continuous_output <- FALSE
        ei_li <- c(ei_li, cox, log, rf)
    }
}

# Put them all together

models <- c(basic, ei_li)
names(models) <- sapply(models, function(x) x$name)
