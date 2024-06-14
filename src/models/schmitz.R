# Models trained on Schmitz et al. (2018)

# Basic (only expression data)

source("src/models/basic.R")

basic <- models

# Early integration with pre-selected features

log_disc_ipi = Model$new(
    name = "ei log with disc IPI",
    fitter = ptk_zerosum,
    directory = "logistic/3-early-int/disc-ipi",
    split_index = 1:5,
    time_cutoffs = c(1.75),
    hyperparams = list(family = "binomial", alpha = 1, zeroSum = FALSE, 
        exclude_pheno_from_lasso = TRUE), 
    include_from_discrete_pheno = c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
        "n_extranodal_sites>1", "ann_arbor_stage>2"),
    combine_n_max_categorical_features = 1,
    continuous_output = TRUE
)
ei <- list(log_disc_ipi)

# Other base features & standardize
names <- c("cont IPI", "IPI score continuous", "IPI group")
directories <- c("cont-ipi", "ipi-score-cont", "ipi-group")
include_discrete <- list(NULL, NULL, c("ipi_group"))
include_continuous <- list(c("age", "ldh_ratio", "ecog_performance_status", 
    "n_extranodal_sites", "ann_arbor_stage"), c("ipi"), NULL)
for (i in seq_along(names)) {
    model <- log_disc_ipi$clone()
    model$name <- stringr::str_replace(model$name, "disc IPI", names[i]) 
    model$directory <- stringr::str_replace(model$directory, "disc-ipi", 
        directories[i])
    model$include_from_discrete_pheno <- include_discrete[[i]]
    model$include_from_continuous_pheno <- include_continuous[[i]]
    ei <- c(ei, model)
}
for (i in seq_along(ei)) {
    model_std <- ei[[i]]$clone()
    model_std$name <- paste0(model_std$name, " std")
    model_std$directory <- paste0(model_std$directory, "-std")
    model_std$hyperparams$standardize <- TRUE
    model_std$hyperparams$exclude_pheno_from_lasso <- FALSE
    ei <- c(ei, model_std)
}
# Same for Cox
for (i in seq_along(ei)) {
    model <- ei[[i]]$clone()
    model$name <- stringr::str_replace(model$name, "log", "cox")
    model$directory <- stringr::str_replace(model$directory, "logistic", 
        "cox")
    model$hyperparams[["family"]] <- "cox"
    ei <- c(ei, model)
}

# No more cox, no more standardization (they suck)
model_names <- sapply(ei, function(x) x$name)
hopeful_names <- c(
    "ei log with disc IPI", 
    "ei log with cont IPI", 
    "ei log with IPI score continuous", 
    "ei log with IPI group"
)
hopefuls <- ei[model_names %in% hopeful_names]
append_to_name <- c("abc", "gene subtype", "abc, gene subtype")
append_to_directory <- c("abc", "gene-subtype", "abc-gene-subtype")
append_to_disc_feat <- list(
    c("gene_expression_subgroup"),
    c("genetic_subtype"),
    c("gene_expression_subgroup", "genetic_subtype")
)
for(i in seq_along(hopefuls)) {
    for (j in seq_along(append_to_name)) {
        model <- hopefuls[[i]]$clone()
        model$name <- paste0(model$name, ", ", append_to_name[j])
        model$directory <- paste0(model$directory, "-", append_to_directory[j])
        model$include_from_discrete_pheno <- c(model$include_from_discrete_pheno, append_to_disc_feat[[j]])
        ei <- c(ei, model)
    }
}

# No genomic data involved
# Random Forest
rf_disc_ipi = Model$new(
    name = "rf no expr with disc IPI",
    directory = "rf/disc-ipi",
    fitter = hypertune(ptk_ranger, error = "error_rate"),
    split_index = 1:5,
    time_cutoffs = c(1.75),
    hyperparams = list(
        num.trees = 1000, 
        mtry = seq(0.8, 1.2, 0.04),
        rel_mtry = TRUE,
        min.node.size = 1:10,
        classification = TRUE,
        skip_on_invalid_input = TRUE
    ),
    include_from_discrete_pheno = c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
        "n_extranodal_sites>1", "ann_arbor_stage>2"),
    include_expr = FALSE,
    continuous_output = FALSE
)
no_expr <- list(rf_disc_ipi)

for (i in seq_along(names)) { # expand to other base features
    model <- rf_disc_ipi$clone()
    model$name <- stringr::str_replace(model$name, "disc IPI", names[i])
    model$directory <- stringr::str_replace(model$directory, "disc-ipi", 
        directories[i])
    model$include_from_discrete_pheno <- include_discrete[[i]]
    model$include_from_continuous_pheno <- include_continuous[[i]]
    no_expr <- c(no_expr, model)
}
for(i in seq_along(no_expr)) {
    for (j in seq_along(append_to_name)) { # add more features
        model <- no_expr[[i]]$clone()
        model$name <- paste0(model$name, ", ", append_to_name[j])
        model$directory <- paste0(model$directory, "-", append_to_directory[j])
        model$include_from_discrete_pheno <- c(model$include_from_discrete_pheno, append_to_disc_feat[[j]])
        no_expr <- c(no_expr, model)
    }
}
for(i in seq_along(no_expr)) { # logistic instead of rf
    model <- no_expr[[i]]$clone()
    model$name <- stringr::str_replace(model$name, "^rf", "log")
    model$directory <- stringr::str_replace(model$directory, "^rf", 
        "logistic/3-early-int/nil")
    model$fitter <- ptk_zerosum
    model$hyperparams <- list(family = "binomial", zeroSum = FALSE, 
        standardize = TRUE, exclude_pheno_from_lasso = FALSE)
    model$continuous_output <- TRUE
    no_expr <- c(no_expr, model)
}

ei <- c(ei, no_expr)

# Late integration with pre-selected features

log_rf_pcv_disc_ipi <- Model$new(
    name = "log-rf pcv with disc IPI",
    fitter = nested_pseudo_cv,
    directory = "logistic/2-late-int/log-rf-pcv-disc-ipi",
    split_index = 1:5,
    time_cutoffs = c(1.75), # 2.),
    hyperparams = list(
        fitter1 = ptk_zerosum,
        fitter2 = hypertune(ptk_ranger, error = "error_rate"),
        hyperparams1 = list(
            family = "binomial",
            alpha = 1,
            zeroSum = FALSE,
            nFold = 10
        ),
        hyperparams2 = list(
            num.trees = 1000, 
            mtry = seq(0.8, 1.2, 0.04),
            rel_mtry = TRUE,
            min.node.size = 1:10,
            classification = TRUE,
            skip_on_invalid_input = TRUE
        )
    ),
    include_from_discrete_pheno = c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
        "n_extranodal_sites>1", "ann_arbor_stage>2"),
    continuous_output = FALSE
)
li <- list(log_rf_pcv_disc_ipi)

names <- c("cont IPI", "IPI score continuous", "IPI group")
directories <- c("cont-ipi", "ipi-score-cont", "ipi-group")
include_discrete <- list(NULL, NULL, c("ipi_group"))
include_continuous <- list(c("age", "ldh_ratio", "ecog_performance_status", 
    "n_extranodal_sites", "ann_arbor_stage"), c("ipi"), NULL)
for (i in seq_along(names)) {
    model <- log_rf_pcv_disc_ipi$clone()
    model$name <- paste0("log-rf pcv with ", names[i])
    model$directory <- paste0("logistic/2-late-int/log-rf-pcv-", directories[i])
    model$include_from_discrete_pheno <- include_discrete[[i]]
    model$include_from_continuous_pheno <- include_continuous[[i]]
    li <- c(li, model)
}

append_to_name <- c("abc", "gene subtype", "abc, gene subtype")
append_to_directory <- c("abc", "gene-subtype", "abc-gene-subtype")
append_to_disc_feat <- list(
    c("gene_expression_subgroup"),
    c("genetic_subtype"),
    c("gene_expression_subgroup", "genetic_subtype")
)
for(i in seq_along(li)) {
    for (j in seq_along(append_to_name)) {
        model <- li[[i]]$clone()
        model$name <- paste0(model$name, ", ", append_to_name[j])
        model$directory <- paste0(model$directory, "-", append_to_directory[j])
        model$include_from_discrete_pheno <- c(model$include_from_discrete_pheno, append_to_disc_feat[[j]])
        li <- c(li, model)
    }
}

# No IPI whatsoever

log_rf_pcv_abc <- li[[1]]$clone()
log_rf_pcv_abc$name <- "log-rf pcv with abc"
log_rf_pcv_abc$directory <- "logistic/2-late-int/log-rf-pcv-abc"
log_rf_pcv_abc$include_from_continuous_pheno <- NULL
log_rf_pcv_abc$include_from_discrete_pheno <- c("gene_expression_subgroup")

log_rf_pcv_abc_gene <- log_rf_pcv_abc$clone()
log_rf_pcv_abc_gene$name <- "log-rf pcv with ABC/GCB and gene subtype"
log_rf_pcv_abc_gene$directory <- "logistic/2-late-int/log-rf-pcv-abc-gene"
log_rf_pcv_abc_gene$include_from_discrete_pheno <- c("gene_expression_subgroup", 
    "genetic_subtype")

log_rf_pcv_gene <- log_rf_pcv_abc_gene$clone()
log_rf_pcv_gene$name <- "log-rf pcv with gene subtype"
log_rf_pcv_gene$directory <- "logistic/2-late-int/log-rf-pcv-gene"
log_rf_pcv_gene$include_from_discrete_pheno <- c("genetic_subtype")

li <- c(li, list(log_rf_pcv_abc, log_rf_pcv_abc_gene, log_rf_pcv_gene))

# Logistic instead of random forest as late model

for (i in seq_along(li)) {
    model <- li[[i]]$clone()
    model$name <- stringr::str_replace(model$name, "log-rf", "log-log")
    model$directory <- stringr::str_replace(model$directory, "log-rf", "log-log") 
    model$hyperparams[["fitter2"]] <- ptk_zerosum
    model$hyperparams[["hyperparams2"]] <- list(
        family = "binomial",
        zeroSum = FALSE,
        standardize = TRUE,
        exclude_pheno_from_lasso = FALSE,
        nFold = 10
    )
    model$continuous_output <- TRUE
    li <- c(li, model)
}

# Binary output from early logistic model

for (i in seq_along(li)) {
    model <- li[[i]]$clone()
    model$name <- paste0("binary ", model$name)
    model$directory <- paste0(dirname(model$directory), "/bin-", 
        basename(model$directory))
    model$hyperparams[["hyperparams1"]][["binarize_predictions"]] <- 0.5
    li <- c(li, model)
}

# Models with all features and combinations

include_from_discrete_pheno <- c("gender", "ipi_group", "gene_expression_subgroup",
    "genetic_subtype")

ipi_group <- Model$new(
    name = "log-log pcv comb 4 with IPI group, all",
    fitter = nested_pseudo_cv,
    directory = "logistic/2-late-int/log-log-pcv-comb-4-ipi-group-all",
    split_index = 1:5,
    time_cutoffs = c(1.75, 2),
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
    include_from_continuous_pheno = NULL,
    include_expr = TRUE,
    combine_n_max_categorical_features = 4,
    combined_feature_min_positive_ratio = 0.05,
    continuous_output = TRUE
)

ipi_disc <- ipi_group$clone()
ipi_disc$name <- "log-log pcv comb 4 with disc IPI, all"
ipi_disc$directory <- "logistic/2-late-int/log-log-pcv-comb-4-disc-ipi-all"
ifdp <- ipi_disc$include_from_discrete_pheno
ifdp <- ifdp[ifdp != "ipi_group"]
ipi_disc$include_from_discrete_pheno <- c(ifdp, "age>60", "ldh_ratio>1", 
    "ecog_performance_status>1", "n_extranodal_sites>1", "ann_arbor_stage>2")

ipi_cont <- ipi_group$clone()
ipi_cont$name <- "log-log pcv comb 4 with IPI score cont, all"
ipi_cont$directory <- "logistic/2-late-int/log-log-pcv-comb-4-ipi-score-cont-all"
ifdp <- ipi_cont$include_from_discrete_pheno
ifdp <- ifdp[ifdp != "ipi_group"]
ipi_cont$include_from_discrete_pheno <- ifdp
ipi_cont$include_from_continuous_pheno <- c("ipi")

ipi_all <- ipi_group$clone()
ipi_all$name <- "log-log pcv comb 4 with all IPI"
ipi_all$directory <- "logistic/2-late-int/log-log-pcv-comb-4-all-ipi"
ipi_all$include_from_discrete_pheno <- c(ipi_group$include_from_discrete_pheno, 
    "age>60", "ldh_ratio>1", "ecog_performance_status>1", "n_extranodal_sites>1", 
    "ann_arbor_stage>2")
ipi_all$include_from_continuous_pheno <- c("ipi", "age", "ldh_ratio", 
    "ecog_performance_status", "n_extranodal_sites", "ann_arbor_stage")

all_combo <- list(ipi_group, ipi_disc, ipi_cont, ipi_all)

for(model in all_combo[1:4]){
    model_ei <- model$clone()
    model_ei$name <- stringr::str_replace(model$name, "-log pcv", " ei")
    dir <- stringr::str_replace(model$directory, "log-pcv", "ei")
    model_ei$directory <- stringr::str_replace(dir, "2-late-int", "3-early-int")
    model_ei$fitter <- ptk_zerosum
    model_ei$hyperparams <- list(family = "binomial", alpha = 1, zeroSum = FALSE,
        standardize = TRUE, exclude_pheno_from_lasso = FALSE)
    all_combo <- c(all_combo, model_ei)
}

for (model in all_combo[1:4]) {
    rf <- model$clone()
    rf$name <- stringr::str_replace(model$name, "log-log", "log-rf")
    rf$directory <- stringr::str_replace(model$directory, "log-log", "log-rf")
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
    cox$name <- stringr::str_replace(model$name, "log-log", "log-cox")
    cox$directory <- stringr::str_replace(cox$directory, "log-log", "log-cox")
    cox$hyperparams[["hyperparams2"]][["family"]] <- "cox"
    all_combo <- c(all_combo, rf, cox)
}

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
        no_expr_cox <- no_expr_log$clone()
        no_expr_cox$name <- stringr::str_replace(no_expr_cox$name, "log ei", "cox ei")
        dir <- stringr::str_replace(no_expr_cox$directory, "logistic", "cox")
        no_expr_cox$directory <- stringr::str_replace(dir, "log-ei", "cox-ei")
        no_expr_cox$hyperparams[["family"]] <- "cox"
        all_combo <- c(all_combo, no_expr_log, no_expr_rf, no_expr_cox)
    }
}

# Put them all together

models <- c(basic, ei, li, all_combo)
names(models) <- sapply(models, function(x) x$name)