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

# Model for new data sets where you cannot try out everything
the_best <- list()
for (model in models) {
    if(!stringr::str_detect(model$name, "gene subtype")) {
        the_best <- c(the_best, model)
    }
}
