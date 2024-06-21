# Models to be trained on Schmitz et al. (2018)

# Basic (only expression data)

source("src/models/basic.R")

basic <- general

# Models with all features and combinations

# Late integration

include_from_discrete_pheno <- c("gender", "ipi_group", "gene_expression_subgroup",
    "genetic_subtype", "lamis_high")

ipi_group <- Model$new(
    name = "log-log with IPI group, all",
    fitter = nested_pseudo_cv,
    directory = "logistic/2-late-int/log-log-ipi-group-all",
    split_index = 1:5,
    time_cutoffs = c(1.75, 2),
    val_error_fun = neg_roc_auc,
    hyperparams = list(
        fitter1 = ptk_zerosum,
        fitter2 = ptk_zerosum,
        hyperparams1 = list(
            family = "binomial",
            alpha = 1,
            zeroSum = FALSE,
            nFold = 10
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
    include_from_continuous_pheno = "lamis_score",
    include_expr = TRUE,
    combine_n_max_categorical_features = 1:4,
    combined_feature_min_positive_ratio = 0.05,
    continuous_output = TRUE
)

ipi_disc <- ipi_group$clone()
ipi_disc$name <- "log-log with disc IPI, all"
ipi_disc$directory <- "logistic/2-late-int/log-log-disc-ipi-all"
ifdp <- ipi_disc$include_from_discrete_pheno
ifdp <- ifdp[ifdp != "ipi_group"]
ipi_disc$include_from_discrete_pheno <- c(ifdp, "age>60", "ldh_ratio>1", 
    "ecog_performance_status>1", "n_extranodal_sites>1", "ann_arbor_stage>2")

ipi_cont <- ipi_group$clone()
ipi_cont$name <- "log-log with IPI score cont, all"
ipi_cont$directory <- "logistic/2-late-int/log-log-ipi-score-cont-all"
ifdp <- ipi_cont$include_from_discrete_pheno
ifdp <- ifdp[ifdp != "ipi_group"]
ipi_cont$include_from_discrete_pheno <- ifdp
ipi_cont$include_from_continuous_pheno <- c("ipi", "lamis_score")

ipi_all <- ipi_group$clone()
ipi_all$name <- "log-log with all IPI"
ipi_all$directory <- "logistic/2-late-int/log-log-all-ipi"
ipi_all$include_from_discrete_pheno <- c(ipi_group$include_from_discrete_pheno, 
    "age>60", "ldh_ratio>1", "ecog_performance_status>1", "n_extranodal_sites>1", 
    "ann_arbor_stage>2")
ipi_all$include_from_continuous_pheno <- c("ipi", "age", "ldh_ratio", 
    "ecog_performance_status", "n_extranodal_sites", "ann_arbor_stage", "lamis_score")

all_combo <- list(ipi_group, ipi_disc, ipi_cont, ipi_all)

# Same for early integration

for(model in all_combo[1:4]){
    model_ei <- model$clone()
    model_ei$name <- stringr::str_replace(model$name, "-log", " ei")
    dir <- stringr::str_replace(model$directory, "log-log", "log-ei")
    model_ei$directory <- stringr::str_replace(dir, "2-late-int", "3-early-int")
    model_ei$fitter <- ptk_zerosum
    model_ei$hyperparams <- list(family = "binomial", alpha = 1, zeroSum = FALSE,
        standardize = TRUE, exclude_pheno_from_lasso = FALSE)
    all_combo <- c(all_combo, model_ei)
}

# rf as late model

for (model in all_combo[1:4]) {
    rf <- model$clone()
    rf$name <- stringr::str_replace(model$name, "log-log", "log-rf")
    rf$directory <- stringr::str_replace(model$directory, "log-log", "log-rf")
    rf$val_error_fun <- error_rate
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
    cox <- model$clone()
    cox$name <- stringr::str_replace(model$name, "log-log", "log-cox")
    cox$directory <- stringr::str_replace(cox$directory, "log-log", "log-cox")
    cox$hyperparams[["hyperparams2"]][["family"]] <- "cox"
    all_combo <- c(all_combo, rf, cox)
}

# Early integration without expression

for (model in all_combo) {
    if (stringr::str_detect(model$directory, "3-early-int")) {
        # Logistic
        no_expr_log <- model$clone()
        no_expr_log$name <- paste(model$name, "no expr")
        no_expr_log$directory <- paste0(model$directory, "-no-expr")
        no_expr_log$include_expr <- FALSE
        # rf
        no_expr_rf <- no_expr_log$clone()
        no_expr_rf$name <- stringr::str_replace(no_expr_rf$name, "log ei", "rf ei")
        no_expr_rf$directory <- stringr::str_replace(no_expr_rf$directory, "log-ei", "rf-ei")
        no_expr_rf$val_error_fun <- error_rate
        no_expr_rf$fitter <- hypertune(ptk_ranger, select = TRUE)
        no_expr_rf$hyperparams <- list(
            num.trees = 1000,
            min.node.size = 1:10, 
            mtry = seq(0.8, 1.2, 0.04),
            rel_mtry = TRUE,
            classification = TRUE,
            skip_on_invalid_input = TRUE
        )
        no_expr_rf$continuous_output <- FALSE
        # Cox
        no_expr_cox <- no_expr_log$clone()
        no_expr_cox$name <- stringr::str_replace(no_expr_cox$name, "log ei", "cox ei")
        dir <- stringr::str_replace(no_expr_cox$directory, "logistic", "cox")
        no_expr_cox$directory <- stringr::str_replace(dir, "log-ei", "cox-ei")
        no_expr_cox$hyperparams[["family"]] <- "cox"
        all_combo <- c(all_combo, no_expr_log, no_expr_rf, no_expr_cox)
    }
}

# Put them all together

models <- c(basic, all_combo)
names(models) <- sapply(models, function(x) x$name)