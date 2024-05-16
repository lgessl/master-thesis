# LATE INTEGRATION

# Random forest as late model

# Train a logistic model on the high-dimensional, genomic part of the data,
# then train a random forest on the logistic model's prediction and some more 
# features. 

# Which features do we integrate late? 
# - for the IPI features: none, continuous, discrete, score categorical, 
#   score continuous,
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
            num.trees = seq(100, 300, by = 100), 
            mtry = 1:6,
            min.node.size = 1:5, 
            classification = TRUE
        )
    ),
    response_type = "binary",
    include_from_discrete_pheno = c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
        "n_extranodal_sites>1", "ann_arbor_stage>2")
)

log_rf_pcv_disc_ipi_abc <- log_rf_pcv_disc_ipi$clone()
log_rf_pcv_disc_ipi_abc$name <- "log-rf pcv with disc IPI and ABC/GCB"
log_rf_pcv_disc_ipi_abc$directory <- "logistic/2-late-int/log-rf-pcv-disc-ipi-abc"
log_rf_pcv_disc_ipi_abc$include_from_discrete_pheno <- c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
    "n_extranodal_sites>1", "ann_arbor_stage>2", "gene_expression_subgroup")

log_rf_pcv_disc_ipi_abc_gene <- log_rf_pcv_disc_ipi_abc$clone()
log_rf_pcv_disc_ipi_abc_gene$name <- "log-rf pcv with disc IPI, ABC/GCB and gene subtype"
log_rf_pcv_disc_ipi_abc_gene$directory <- "logistic/2-late-int/log-rf-pcv-disc-ipi-abc-gene"
log_rf_pcv_disc_ipi_abc_gene$include_from_discrete_pheno <- c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
    "n_extranodal_sites>1", "ann_arbor_stage>2", "gene_expression_subgroup", 
    "genetic_subtype")

log_rf_pcv_disc_ipi_gene <- log_rf_pcv_disc_ipi_abc_gene$clone()
log_rf_pcv_disc_ipi_gene$name <- "log-rf pcv with disc IPI and gene subtype"
log_rf_pcv_disc_ipi_gene$directory <- "logistic/2-late-int/log-rf-pcv-disc-ipi-gene"
log_rf_pcv_disc_ipi_gene$include_from_discrete_pheno <- c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
    "n_extranodal_sites>1", "ann_arbor_stage>2", "genetic_subtype")

# Five continuous IPI features

log_rf_pcv_cont_ipi <- log_rf_pcv_disc_ipi$clone()
log_rf_pcv_cont_ipi$name <- "log-rf pcv with cont IPI"
log_rf_pcv_cont_ipi$directory <- "logistic/2-late-int/log-rf-pcv-cont-ipi"
log_rf_pcv_cont_ipi$include_from_discrete_pheno <- NULL
log_rf_pcv_cont_ipi$include_from_continuous_pheno <- c("age", "ldh_ratio", "ecog_performance_status", 
    "n_extranodal_sites", "ann_arbor_stage") 

log_rf_pcv_cont_ipi_abc <- log_rf_pcv_cont_ipi$clone()
log_rf_pcv_cont_ipi_abc$name <- "log-rf pcv with cont IPI and ABC/GCB"
log_rf_pcv_cont_ipi_abc$directory <- "logistic/2-late-int/log-rf-pcv-cont-ipi-abc"
log_rf_pcv_cont_ipi_abc$include_from_discrete_pheno <- c("gene_expression_subgroup")

log_rf_pcv_cont_ipi_gene <- log_rf_pcv_cont_ipi_abc$clone()
log_rf_pcv_cont_ipi_gene$name <- "log-rf pcv with cont IPI and gene subtype"
log_rf_pcv_cont_ipi_gene$directory <- "logistic/2-late-int/log-rf-pcv-cont-ipi-gene"
log_rf_pcv_cont_ipi_gene$include_from_discrete_pheno <- c("genetic_subtype")

log_rf_pcv_cont_ipi_abc_gene <- log_rf_pcv_cont_ipi_gene$clone()
log_rf_pcv_cont_ipi_abc_gene$name <- "log-rf pcv with cont IPI, ABC/GCB and gene subtype"
log_rf_pcv_cont_ipi_abc_gene$directory <- "logistic/2-late-int/log-rf-pcv-cont-ipi-abc-gene"
log_rf_pcv_cont_ipi_abc_gene$include_from_discrete_pheno <- c("gene_expression_subgroup", 
    "genetic_subtype")  

# No IPI whatsoever

log_rf_pcv_abc <- log_rf_pcv_cont_ipi_abc$clone()
log_rf_pcv_abc$name <- "log-rf pcv with ABC/GCB"
log_rf_pcv_abc$directory <- "logistic/2-late-int/log-rf-pcv-abc"
log_rf_pcv_abc$include_from_continuous_pheno <- NULL

log_rf_pcv_abc_gene <- log_rf_pcv_abc$clone()
log_rf_pcv_abc_gene$name <- "log-rf pcv with ABC/GCB and gene subtype"
log_rf_pcv_abc_gene$directory <- "logistic/2-late-int/log-rf-pcv-abc-gene"
log_rf_pcv_abc_gene$include_from_discrete_pheno <- c("gene_expression_subgroup", 
    "genetic_subtype")

log_rf_pcv_gene <- log_rf_pcv_abc_gene$clone()
log_rf_pcv_gene$name <- "log-rf pcv with gene subtype"
log_rf_pcv_gene$directory <- "logistic/2-late-int/log-rf-pcv-gene"
log_rf_pcv_gene$include_from_discrete_pheno <- c("genetic_subtype")

# IPI score as as a categorical variable

# Not included since there are often features in the training data that don't come 
# up in the test data or vice versa.

# IPI score as a continuous variable

log_rf_pcv_ipi_score_cont <- log_rf_pcv_ipi_cont$clone()
log_rf_pcv_ipi_score_cont$name <- "log-rf pcv with IPI score continuous"
log_rf_pcv_ipi_score_cont$directory <- "logistic/2-late-int/log-rf-pcv-ipi-score-cont"
log_rf_pcv_ipi_score_cont$include_from_continuous_pheno <- c("ipi")

log_rf_pcv_ipi_score_cont_abc <- log_rf_pcv_ipi_score_cont$clone()
log_rf_pcv_ipi_score_cont_abc$name <- "log-rf pcv with IPI score continuous and ABC/GCB"
log_rf_pcv_ipi_score_cont_abc$directory <- "logistic/2-late-int/log-rf-pcv-ipi-score-cont-abc"
log_rf_pcv_ipi_score_cont_abc$include_from_discrete_pheno <- c("gene_expression_subgroup")

log_rf_pcv_ipi_score_cont_gene <- log_rf_pcv_ipi_score_cont_abc$clone()
log_rf_pcv_ipi_score_cont_gene$name <- "log-rf pcv with IPI score continuous and gene subtype"
log_rf_pcv_ipi_score_cont_gene$directory <- "logistic/2-late-int/log-rf-pcv-ipi-score-cont-gene"
log_rf_pcv_ipi_score_cont_gene$include_from_discrete_pheno <- c("genetic_subtype")

log_rf_pcv_ipi_score_cont_abc_gene <- log_rf_pcv_ipi_score_cont_gene$clone()
log_rf_pcv_ipi_score_cont_abc_gene$name <- "log-rf pcv with IPI score continuous, ABC/GCB and gene subtype"
log_rf_pcv_ipi_score_cont_abc_gene$directory <- "logistic/2-late-int/log-rf-pcv-ipi-score-cont-abc-gene"
log_rf_pcv_ipi_score_cont_abc_gene$include_from_discrete_pheno <- c("gene_expression_subgroup", 
    "genetic_subtype")

# IPI group

log_rf_pcv_ipi_group <- log_rf_pcv_disc_ipi$clone()
log_rf_pcv_ipi_group$name <- "log-rf pcv with IPI group"
log_rf_pcv_ipi_group$directory <- "logistic/2-late-int/log-rf-pcv-ipi-group"
log_rf_pcv_ipi_group$include_from_discrete_pheno <- c("ipi_group")

log_rf_pcv_ipi_group_abc <- log_rf_pcv_ipi_group$clone()
log_rf_pcv_ipi_group_abc$name <- "log-rf pcv with IPI group and ABC/GCB"
log_rf_pcv_ipi_group_abc$directory <- "logistic/2-late-int/log-rf-pcv-ipi-group-abc"
log_rf_pcv_ipi_group_abc$include_from_discrete_pheno <- c("ipi_group", "gene_expression_subgroup")

log_rf_pcv_ipi_group_gene <- log_rf_pcv_ipi_group_abc$clone()
log_rf_pcv_ipi_group_gene$name <- "log-rf pcv with IPI group and gene subtype"
log_rf_pcv_ipi_group_gene$directory <- "logistic/2-late-int/log-rf-pcv-ipi-group-gene"
log_rf_pcv_ipi_group_gene$include_from_discrete_pheno <- c("ipi_group", "genetic_subtype")

log_rf_pcv_ipi_group_abc_gene <- log_rf_pcv_ipi_group_gene$clone()
log_rf_pcv_ipi_group_abc_gene$name <- "log-rf pcv with IPI group, ABC/GCB and gene subtype"
log_rf_pcv_ipi_group_abc_gene$directory <- "logistic/2-late-int/log-rf-pcv-ipi-group-abc-gene"
log_rf_pcv_ipi_group_abc_gene$include_from_discrete_pheno <- c("ipi_group", "gene_expression_subgroup", 
    "genetic_subtype")

models <- list(
    log_rf_pcv_disc_ipi,
    log_rf_pcv_disc_ipi_abc,
    log_rf_pcv_disc_ipi_abc_gene,
    log_rf_pcv_disc_ipi_gene,
    log_rf_pcv_cont_ipi,
    log_rf_pcv_cont_ipi_abc,
    log_rf_pcv_cont_ipi_gene,
    log_rf_pcv_cont_ipi_abc_gene,
    log_rf_pcv_abc,
    log_rf_pcv_abc_gene,
    log_rf_pcv_gene,
    log_rf_pcv_ipi_score_cont,
    log_rf_pcv_ipi_score_cont_abc,
    log_rf_pcv_ipi_score_cont_gene,
    log_rf_pcv_ipi_score_cont_abc_gene,
    log_rf_pcv_ipi_group,
    log_rf_pcv_ipi_group_abc,
    log_rf_pcv_ipi_group_gene,
    log_rf_pcv_ipi_group_abc_gene
)

# Logistic instead of random forest as late model

log_late_list <- vector("list", length(models))
for (i in seq_along(models)) {
    model <- models[[i]]$clone()
    model$name <- stringr::str_replace(model$name, "log-rf", "log-log")
    model$directory <- stringr::str_replace(model$directory, "log-rf", "log-log") 
    model$hyperparams$fitter2 <- ptk_zerosum
    model$hyperparams$hyperparams2 <- list(
        family = "binomial",
        zeroSum = FALSE,
        lambda = 0,
        nFold = 10, # only provide so zeroSum does a CV at all
        binarize_predictions = 0.5
    )
    model$hyperparams$oob <- c(FALSE, FALSE)
    model$hyperparams$metric <- "binomial_log_likelihood"
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