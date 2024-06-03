# LATE INTEGRATION

# Random forest as late model

# Train a logistic model on the high-dimensional, genomic part of the data,
# then train a random forest on the logistic model's prediction and some more 
# features. 

# Which features do we integrate late? 
# - for the IPI features: none, continuous, discrete, score continuous
# - for ABC/GCB,
# - genetic subgroup.

# Five discretized IPI features
log_rf_pcv_disc_ipi <- Model$new(
    name = "log-rf pcv with disc IPI",
    fitter = nested_pseudo_cv,
    directory = "logistic/2-late-int/log-rf-pcv-disc-ipi",
    split_index = 1:5,
    time_cutoffs = c(1.75), # 2.),
    hyperparams = list(
        fitter1 = ptk_zerosum,
        fitter2 = ptk_ranger,
        hyperparams1 = list(
            family = "binomial",
            alpha = 1,
            zeroSum = FALSE,
            nFold = 10
        ),
        hyperparams2 = list(
            num.trees = 600,
            mtry = 1:6,
            min.node.size = 1:5, 
            classification = TRUE,
            skip_on_invalid_input = TRUE
        )
    ),
    response_type = "binary",
    include_from_discrete_pheno = c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
        "n_extranodal_sites>1", "ann_arbor_stage>2")
)
models <- list(log_rf_pcv_disc_ipi)

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
    models <- append(models, model)
}

append_to_name <- c("abc", "gene subtype", "abc, gene subtype")
append_to_directory <- c("abc", "gene-subtype", "abc-gene-subtype")
append_to_disc_feat <- list(
    c("gene_expression_subgroup"),
    c("genetic_subtype"),
    c("gene_expression_subgroup", "genetic_subtype")
)
for(i in seq_along(models)) {
    for (j in seq_along(append_to_name)) {
        model <- models[[i]]$clone()
        model$name <- paste0(model$name, ", ", append_to_name[j])
        model$directory <- paste0(model$directory, "-", append_to_directory[j])
        model$include_from_discrete_pheno <- c(model$include_from_discrete_pheno, append_to_disc_feat[[j]])
        models <- append(models, model)
    }
}

# No IPI whatsoever

log_rf_pcv_abc <- models[[1]]$clone()
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

models <- c(models, list(log_rf_pcv_abc, log_rf_pcv_abc_gene, log_rf_pcv_gene))

# Logistic instead of random forest as late model

log_late_list <- vector("list", length(models))
for (i in seq_along(models)) {
    model <- models[[i]]$clone()
    model$name <- stringr::str_replace(model$name, "log-rf", "log-log")
    model$directory <- stringr::str_replace(model$directory, "log-rf", "log-log") 
    model$hyperparams[["fitter2"]] <- ptk_zerosum
    model$hyperparams[["hyperparams2"]] <- list(
        family = "binomial",
        zeroSum = FALSE,
        lambda = 0,
        nFold = 10 # only provide so zeroSum does a CV at all
    )
    model$hyperparams[["metric"]] <- "binomial_log_likelihood"
    log_late_list[[i]] <- model
}
models <- c(models, log_late_list)

# Binary output from early logistic model

binary_log_list <- vector("list", length(models))
for (i in seq_along(models)) {
    model <- models[[i]]$clone()
    model$name <- paste0("binary ", model$name)
    model$directory <- paste0(dirname(model$directory), "/bin-", 
        basename(model$directory))
    model$hyperparams[["hyperparams1"]][["binarize_predictions"]] <- 0.5
    binary_log_list[[i]] <- model
}

models <- c(models, binary_log_list)

# For general new data sets
# Model for new data sets where you cannot try out everything
exclude_patterns <- c("gene subtype", "cont ipi")
exclude_patterns <- paste(exclude_patterns, collapse = "|")
exclude_patterns <- stringr::regex(exclude_patterns, ignore_case = TRUE)
the_best <- list()
for(model in models){
    # Other data sets don't include gene subtype
    if(!stringr::str_detect(model$name, exclude_patterns)){
        the_best <- c(the_best, model$clone())
    }
}

# Reddy
for_reddy <- list()
include_from_discrete_pheno <- c("gender", "ipi_group", "b_symptoms_at_diagnosis", 
    "response_to_initial_therapy", "testicular_involvement", "cns_involvement",
    "cns_relapse", "myc_high_expr", "bcl2_high_expr", "bcl6_high_expr", 
    "myc_translocation_seq", "bcl2_translocation_seq", "bcl6_translocation_seq",
    "gene_expression_sugroup")

ipi_group <- Model$new(
    name = "log-(cv)log pcv comb 4 with IPI group, all",
    fitter = nested_pseudo_cv,
    directory = "logistic/2-late-int/log-cvlog-pcv-comb-4-ipi-group-all",
    split_index = 1:5,
    time_cutoffs = c(2.5),
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
            nFold = 10
        )
    ),
    response_type = "binary",
    include_from_discrete_pheno = include_from_discrete_pheno,
    include_from_continuous_pheno = NULL,
    include_expr = TRUE,
    combine_n_max_categorical_features = 4,
    combined_feature_min_positive_ratio = 0.05
)

ipi_disc <- ipi_group$clone()
ipi_disc$name <- "log-(cv)log pcv comb 4 with disc IPI, all"
ipi_disc$directory <- "logistic/2-late-int/log-cvlog-pcv-comb-4-disc-ipi-all"
ifdp <- ipi_disc$include_from_discrete_pheno
ifdp <- ifdp[ifdp != "ipi_group"]
ipi_disc$include_from_discrete_pheno <- c(ifdp, "age>60", "ldh_ratio>1", 
    "ecog_performance_status>1", "n_extranodal_sites>1", "ann_arbor_stage>2")
ipi_disc$include_from_discrete_pheno <- ifdp

ipi_cont <- ipi_group$clone()
ipi_cont$name <- "log-(cv)log pcv comb 4 with IPI score cont, all"
ipi_cont$directory <- "logistic/2-late-int/log-cvlog-pcv-comb-4-ipi-score-cont-all"
ifdp <- ipi_cont$include_from_discrete_pheno
ifdp <- ifdp[ifdp != "ipi_group"]
ipi_cont$include_from_discrete_pheno <- ifdp
ipi_cont$include_from_continuous_pheno <- c("ipi")

full <- list(ipi_group, ipi_disc, ipi_cont)
for(model in full){
    model_cox <- model$clone()
    model_cox$name <- stringr::str_replace_all(model$name, "log", "cox")
    dir <- stringr::str_replace(model$directory, "logistic", "cox")
    model_ei$directory <- stringr::str_replace_all(dir, "log", "cox")
    model_cox$hyperparams[["hyperparams1"]][["family"]] <- "cox"
    model_cox$hyperparams[["hyperparams2"]][["family"]] <- "cox"
    model_cox$response_type <- "survival_censored"
    model_cox$time_cutoffs <- c(Inf)
    full <- append(full, model_cox)
}

for(model in full[1:3]){
    model_ei <- model$clone()
    model_ei$name <- stringr::str_replace(model$name, "-(cv)log pcv", " ei")
    dir <- stringr::str_replace(model$directory, "cv-log-pcv", "ei")
    model_ei$directory <- stringr::str_replace(dir, "2-late-int", "3-early-int")
    model_ei$fitter <- ptk_zerosum
    model_ei$hyperparams <- list(family = "binomial", alpha = 1, zeroSum = FALSE,
    standardize = TRUE, exclude_pheno_from_lasso = FALSE)
    full <- append(full, model_ei)
}
for(model in full[7:9]) {
    model_ei <- model$clone()
    model_ei$name <- stringr::str_replace_all(model$name, "log", "cox")
    dir <- stringr::str_replace(model$directory, "logistic", "cox")
    model_ei$directory <- stringr::str_replace_all(dir, "log", "cox")
    model_ei$hyperparams[["family"]] <- "cox"
    model_ei$response_type <- "survival_censored"
    model_ei$time_cutoffs <- c(Inf)
    full <- append(full, model_ei)
}
for_reddy <- c(for_reddy, full)

model_rf <- for_reddy[[1]]$clone()
model_rf$name <- "log-rf pcv comb 4 with all"
model_rf$directory <- "logistic/2-late-int/log-rf-pcv-comb-4-all"
model_rf$hyperparams[["fitter2"]] <- ptk_ranger
model_rf$hyperparams[["hyperparams2"]] <- list(
    num.trees = 600,
    mtry = 1:6, # Wait for number of included discrete features
    min.node.size = 1:5, 
    classification = TRUE,
    skip_on_invalid_input = TRUE
)
# for_reddy <- c(for_reddy, model_rf)

for (model in for_reddy) {
    if (stringr::str_detect(model$directory, "3-early-int")) {
        no_expr <- model$clone()
        no_expr$name <- paste(model$name, "no expr")
        no_expr$directory <- paste0(model$directory, "-no-expr")
        no_expr$include_expr <- FALSE
        for_reddy <- c(for_reddy, no_expr)
    }
}