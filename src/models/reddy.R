# Models trained on Reddy data

# Basic (gene-expression only)

source("src/models/basic.R")

basic <- general
for(i in seq_along(basic)) {
    time_cutoffs <- basic[[i]]$time_cutoffs + 0.5
    time_cutoffs <- unique(c(time_cutoffs, 2.75, 3, 3.25, 3.5))
    basic[[i]]$time_cutoffs <- sort(time_cutoffs)
}

# Models with all features and combinations (-> integrate gene-expression signatures)

# Nested models (early model only predicts from gene-expression levels)
# Vary the IPI format

include_from_discrete_pheno <- c("gender", "ipi_group", "b_symptoms_at_diagnosis", 
    "testicular_involvement", "cns_involvement",
    "myc_high_expr", "bcl2_high_expr", "bcl6_high_expr", 
    "myc_translocation_seq", "bcl2_translocation_seq", "bcl6_translocation_seq",
    "gene_expression_subgroup", "lamis_high")

ipi_group <- Model$new(
    name = "gauss-gauss with IPI group, rest",
    fitter = greedy_nestor,
    directory = "gauss/late-int/gauss-gauss-ipi-group-rest",
    time_cutoffs = 2.5,
    val_error_fun = neg_prec_with_prev_greater(0.17),
    hyperparams = list(
        model1 = basic[["gauss"]],
        fitter2 = ptk_zerosum,
        hyperparams2 = list(
            family = "gaussian",
            alpha = 1,
            zeroSum = FALSE,
            nFold = 1000,
            standardize = TRUE,
            exclude_pheno_from_lasso = FALSE
        )
    ),
    include_from_discrete_pheno = include_from_discrete_pheno,
    include_from_continuous_pheno = "lamis_score",
    include_expr = TRUE,
    combine_n_max_categorical_features = 1:3,
    combined_feature_min_positive_ratio = 0.05,
)

ipi_disc <- ipi_group$clone()
ipi_disc$name <- "gauss-gauss with disc IPI, rest"
ipi_disc$directory <- "gauss/late-int/gauss-gauss-disc-ipi-rest"
ifdp <- ipi_disc$include_from_discrete_pheno
ifdp <- ifdp[ifdp != "ipi_group"]
ipi_disc$include_from_discrete_pheno <- c(ifdp, "age>60", "ldh_ratio>1", 
    "ecog_performance_status>1", "n_extranodal_sites>1", "ann_arbor_stage>2")
ipi_disc$include_from_continuous_pheno <- c("lamis_score")

ipi_cont <- ipi_group$clone()
ipi_cont$name <- "gauss-gauss with IPI score cont, rest"
ipi_cont$directory <- "gauss/late-int/gauss-gauss-ipi-score-cont-rest"
ifdp <- ipi_cont$include_from_discrete_pheno
ifdp <- ifdp[ifdp != "ipi_group"]
ipi_cont$include_from_discrete_pheno <- ifdp
ipi_cont$include_from_continuous_pheno <- c("ipi", "lamis_score")

ipi_all <- ipi_group$clone()
ipi_all$name <- "gauss-gauss with all IPI"
ipi_all$directory <- "gauss/late-int/gauss-gauss-all-ipi-rest"
ipi_all$include_from_discrete_pheno <- c(ipi_group$include_from_discrete_pheno, 
    "age>60", "ldh_ratio>1", "ecog_performance_status>1", "n_extranodal_sites>1", 
    "ann_arbor_stage>2")
ipi_all$include_from_continuous_pheno <- c("ipi", "lamis_score")

ei_li <- list(ipi_group, ipi_disc, ipi_cont, ipi_all)

# Provide all features to a single core model (Gauss) at once

for(model in ei_li[1:4]){
    gauss <- model$clone()
    gauss$name <- stringr::str_replace(model$name, "gauss-gauss", "gauss ei")
    dir <- stringr::str_replace(model$directory, "gauss-gauss", "gauss-ei")
    gauss$directory <- stringr::str_replace(dir, "late-int", "early-int")
    gauss$fitter <- ptk_zerosum
    gauss$hyperparams <- list(family = "gaussian", alpha = 1, zeroSum = FALSE,
        standardize = TRUE, exclude_pheno_from_lasso = FALSE, nFold = 1000)
    ei_li <- c(ei_li, gauss)
}

# More nested models, now with rf, Cox as late models

for (model in ei_li[1:4]) {
    rf <- model$clone()
    rf$name <- stringr::str_replace(model$name, "gauss-gauss", "gauss-rf")
    rf$directory <- stringr::str_replace(model$directory, "gauss-gauss", "gauss-rf")
    rf$hyperparams[["fitter2"]] <- multitune(ptk_ranger)
    rf$hyperparams[["hyperparams2"]] <- list(
        num.trees = 600,
        min.node.size = 1:10,
        mtry = seq(0.8, 1.2, 0.04),
        rel_mtry = TRUE,
        classification = TRUE,
        skip_on_invalid_input = TRUE
    )
    cox <- model$clone()
    cox$name <- stringr::str_replace(model$name, "gauss-gauss", "gauss-cox")
    cox$directory <- stringr::str_replace(model$directory, "gauss-gauss", "gauss-cox")
    cox$hyperparams[["hyperparams2"]][["family"]] <- "cox"
    cox$time_cutoffs <- Inf
    ei_li <- c(ei_li, rf, cox)
}

# Everything-at-once models without gene-expression levels as features
for (model in ei_li) {
    if (stringr::str_detect(model$name, "gauss ei")) {
        gauss <- model$clone()
        gauss$name <- paste(model$name, "no expr")
        gauss$directory <- paste0(model$directory, "-no-expr")
        gauss$include_expr <- FALSE
        cox <- gauss$clone()
        cox$name <- stringr::str_replace(cox$name, "gauss", "cox")
        cox$directory <- stringr::str_replace_all(cox$directory, "gauss", "cox")
        cox$hyperparams[["family"]] <- "cox"
        cox$time_cutoffs <- Inf
        log <- gauss$clone()
        log$name <- stringr::str_replace(log$name, "gauss", "log")
        log$directory <- stringr::str_replace_all(log$directory, "gauss", "log")
        log$hyperparams[["family"]] <- "binomial"
        rf <- cox$clone()
        rf$name <- stringr::str_replace(rf$name, "cox ei", "rf ei")
        rf$directory <- stringr::str_replace_all(cox$directory, "cox", "rf")
        rf$fitter <- multitune(ptk_ranger)
        rf$hyperparams <- list(
            num.trees = 600,
            min.node.size = 1:10, 
            mtry = seq(0.8, 1.2, 0.04),
            rel_mtry = TRUE,
            classification = TRUE,
            skip_on_invalid_input = TRUE
        )
        rf$time_cutoffs <- 2.5
        ei_li <- c(ei_li, gauss, cox, log, rf)
    }
}

# Put them all together

models <- c(basic, ei_li)
names(models) <- sapply(models, function(x) x$name)
prepend_to_directory(models, "models/reddy")