# LATE INTEGRATION

# Random forest

# Logistic regression nested into random forest, trained in pseudo CV 
# Which features do we integrate late? 
# We try out all possibilities 
# - for the IPI features: none, continuous, discrete,
# - for ABC/GCB,
# - genetic subgroup.
# I.e., 3 x 2 x 2 = 12 models.
log_rf_pcv_disc_ipi <- Model$new(
    name = "log-rf pcv with disc IPI",
    fitter = nested_cv_oob,
    directory = "logistic/2-late-int/log-rf-pcv-disc-ipi",
    split_index = 1:5,
    time_cutoffs = c(1.75, 2.),
    hyperparams = list(
        fitter1 = zeroSum::zeroSum,
        fitter2 = ptk_ranger,
        hyperparams1 = list(
            family = "binomial",
            alpha = 1,
            zeroSum = FALSE
        ),
        hyperparams2 = list(
            num.trees = seq(100, 300, by = 100), 
            mtry = 1:6,
            min.node.size = 1:3, 
            classification = TRUE
        ),
        pseudo_cv = TRUE,
        n_folds = 10
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

log_rf_pcv_abc <- log_rf_pcv_cont_ipi_abc$clone()
log_rf_pcv_abc$name <- "log-rf pcv with ABC/GCB"
log_rf_pcv_abc$directory <- "logistic/2-late-int/log-rf-pcv-abc"
log_rf_pcv_abc$include_from_continuous_pheno <- NULL
log_rf_pcv_abc$hyperparams$hyperparams2$mtry <- 1:2

log_rf_pcv_abc_gene <- log_rf_pcv_abc$clone()
log_rf_pcv_abc_gene$name <- "log-rf pcv with ABC/GCB and gene subtype"
log_rf_pcv_abc_gene$directory <- "logistic/2-late-int/log-rf-pcv-abc-gene"
log_rf_pcv_abc_gene$include_from_discrete_pheno <- c("gene_expression_subgroup", 
    "genetic_subtype")
log_rf_pcv_abc_gene$hyperparams$hyperparams2$mtry <- 1:3

log_rf_pcv_gene <- log_rf_pcv_abc_gene$clone()
log_rf_pcv_gene$name <- "log-rf pcv with gene subtype"
log_rf_pcv_gene$directory <- "logistic/2-late-int/log-rf-pcv-gene"
log_rf_pcv_gene$include_from_discrete_pheno <- c("genetic_subtype")
log_rf_pcv_gene$hyperparams$hyperparams2$mtry <- 1:2

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
    log_rf_pcv_gene
)
