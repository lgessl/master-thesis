# EARLY INTEGRATION

# ipi

# add discretized ipi features (as in paper)
# logistic
# ipi penalty = 0
log_disc_ipi = Model$new(
    name = "log with disc IPI feat",
    fitter = ptk_zerosum,
    directory = "logistic/3-early-int/vanilla-disc-ipi-feat",
    split_index = 1:5,
    time_cutoffs = c(1.75),
    hyperparams = list(family = "binomial", alpha = 1, zeroSum = FALSE, 
        exclude_pheno_from_lasso = TRUE), 
    include_from_discrete_pheno = c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
        "n_extranodal_sites>1", "ann_arbor_stage>2"),
    response_type = "binary"
)
# standardize
log_disc_ipi_std <- log_disc_ipi$clone()
log_disc_ipi_std$name <- "log with disc IPI feat std"
log_disc_ipi_std$directory <- "logistic/3-early-int/vanilla-disc-ipi-feat-std"
log_disc_ipi_std$hyperparams$standardize <- TRUE
log_disc_ipi_std$hyperparams$exclude_pheno_from_lasso <- FALSE
# same for cox
# ipi penalty = 0
cv_disc_ipi <- log_disc_ipi$clone()
cv_disc_ipi$name <- "CV with disc IPI feat"
cv_disc_ipi$directory <- "cox/3-early-int/vanilla-disc-ipi-feat"
cv_disc_ipi$hyperparams$family <- "cox"
cv_disc_ipi$response_type <- "survival_censored"
# standardize
cv_disc_ipi_std <- log_disc_ipi_std$clone()
cv_disc_ipi_std$name <- "CV with disc IPI feat std"
cv_disc_ipi_std$directory <- "cox/3-early-int/vanilla-disc-ipi-feat-std"
cv_disc_ipi_std$hyperparams$family <- "cox"
cv_disc_ipi_std$response_type <- "survival_censored"

# Add IPI features as continuous features
# logistic
# ipi penalty = 0
log_cont_ipi <- log_disc_ipi$clone()
log_cont_ipi$name <- "log with cont IPI feat"
log_cont_ipi$directory <- "logistic/3-early-int/vanilla-cont-ipi-feat"
log_cont_ipi$include_from_discrete_pheno <- NULL
log_cont_ipi$include_from_continuous_pheno <- c("age", "ldh_ratio", "ecog_performance_status", 
    "n_extranodal_sites", "ann_arbor_stage")
# standardize
log_cont_ipi_std <- log_cont_ipi$clone()
log_cont_ipi_std$name <- "log with cont IPI feat std"
log_cont_ipi_std$directory <- "logistic/3-early-int/vanilla-cont-ipi-feat-std"
log_cont_ipi_std$hyperparams$standardize <- TRUE
log_cont_ipi_std$hyperparams$exclude_pheno_from_lasso <- FALSE
# same for cox
# ipi penalty = 0
cv_cont_ipi <- log_cont_ipi$clone()
cv_cont_ipi$name <- "CV with cont IPI feat"
cv_cont_ipi$directory <- "cox/3-early-int/vanilla-cont-ipi-feat"
cv_cont_ipi$hyperparams$family <- "cox"
cv_cont_ipi$response_type <- "survival_censored"
# standardize
cv_cont_ipi_std <- log_cont_ipi_std$clone()
cv_cont_ipi_std$name <- "CV with cont IPI feat std"
cv_cont_ipi_std$directory <- "cox/3-early-int/vanilla-cont-ipi-feat-std"
cv_cont_ipi_std$hyperparams$family <- "cox"
cv_cont_ipi_std$response_type <- "survival_censored"

# add ipi as one continuous feature
# logistic
# ipi penalty = 0
log_ipi_score_cont <- log_disc_ipi$clone()
log_ipi_score_cont$name <- "log with IPI score continuous"
log_ipi_score_cont$directory <- "logistic/3-early-int/vanilla-ipi-cont"
log_ipi_score_cont$include_from_continuous_pheno <- "ipi"
log_ipi_score_cont$include_from_discrete_pheno <- NULL
# standardize
log_ipi_score_cont_std <- log_ipi_score_cont$clone()
log_ipi_score_cont_std$name <- "log with IPI score continuous std"
log_ipi_score_cont_std$directory <- "logistic/3-early-int/vanilla-ipi-cont-std"
log_ipi_score_cont_std$hyperparams$standardize <- TRUE
log_ipi_score_cont_std$hyperparams$exclude_pheno_from_lasso <- FALSE   
# same for cox
# ipi penalty = 0
cv_ipi_score_cont <- log_ipi_score_cont$clone()
cv_ipi_score_cont$name <- "CV with IPI score continuous"
cv_ipi_score_cont$directory <- "cox/3-early-int/vanilla-ipi-cont"
cv_ipi_score_cont$hyperparams$family <- "cox"
cv_ipi_score_cont$response_type <- "survival_censored"
# standardize
cv_ipi_score_cont_std <- log_ipi_score_cont_std$clone()
cv_ipi_score_cont_std$name <- "CV with IPI score continuous std"
cv_ipi_score_cont_std$directory <- "cox/3-early-int/vanilla-ipi-cont-std"
cv_ipi_score_cont_std$hyperparams$family <- "cox"
cv_ipi_score_cont_std$response_type <- "survival_censored"

# Add IPI as one categorical feature 

# Not practically feasible

# add ipi group as one discrete feature
# logistic
# ipi penalty = 0
log_ipi_group <- log_disc_ipi$clone()
log_ipi_group$name <- "log with IPI group"
log_ipi_group$directory <- "logistic/3-early-int/vanilla-ipi-group"
log_ipi_group$hyperparams$exclude_pheno_from_lasso <- TRUE
log_ipi_group$include_from_discrete_pheno <- "ipi_group"
# standardize
log_ipi_group_std <- log_ipi_group$clone()
log_ipi_group_std$name <- "log with IPI group std"
log_ipi_group_std$directory <- "logistic/3-early-int/vanilla-ipi-group-std"
log_ipi_group_std$hyperparams$standardize <- TRUE
log_ipi_group_std$hyperparams$exclude_pheno_from_lasso <- FALSE
# same for cox
# ipi penalty = 0
cv_ipi_group <- log_ipi_group$clone()
cv_ipi_group$name <- "CV with IPI group"
cv_ipi_group$directory <- "cox/3-early-int/vanilla-ipi-group"
cv_ipi_group$hyperparams$family <- "cox"
cv_ipi_group$response_type <- "survival_censored"
# standardize
cv_ipi_group_std <- log_ipi_group_std$clone()
cv_ipi_group_std$name <- "CV with IPI group std"
cv_ipi_group_std$directory <- "cox/3-early-int/vanilla-ipi-group-std"
cv_ipi_group_std$hyperparams$family <- "cox"
cv_ipi_group_std$response_type <- "survival_censored"

models <- list(
    log_disc_ipi,
    log_disc_ipi_std,
    cv_disc_ipi,
    cv_disc_ipi_std,
    log_ipi_score_cont,
    log_ipi_score_cont_std,
    cv_ipi_score_cont,
    cv_ipi_score_cont_std,
    log_ipi_group,
    log_ipi_group_std,
    cv_ipi_group,
    cv_ipi_group_std
)

# No more cox, no more standardization (they suck)
hopefuls <- list(
    log_disc_ipi,
    log_cont_ipi,
    log_ipi_score_cont,
    log_ipi_group
)
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
        models <- append(models, model)
    }
}

# No genomic data involved
# Random Forest
rf_disc_ipi = Model$new(
    name = "rf with disc IPI",
    directory = "rf/disc-ipi",
    fitter = ptk_ranger,
    split_index = 1:5,
    time_cutoffs = c(1.75),
    hyperparams = list(
        num.trees = seq(200, 600, by = 100), 
        mtry = 1:3,
        min.node.size = 1:5, 
        classification = TRUE
    ),
    response_type = "binary",
    include_from_discrete_pheno = c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
        "n_extranodal_sites>1", "ann_arbor_stage>2"),
    include_expr = FALSE
)

rf_disc_ipi_abc = rf_disc_ipi$clone()
rf_disc_ipi_abc$name = "rf with disc IPI and ABC/GCB"
rf_disc_ipi_abc$directory = "rf/disc-ipi-abc"
rf_disc_ipi_abc$include_from_discrete_pheno = c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
    "n_extranodal_sites>1", "ann_arbor_stage>2", "gene_expression_subgroup")

rf_disc_ipi_abc_gene = rf_disc_ipi_abc$clone()
rf_disc_ipi_abc_gene$name = "rf with disc IPI, ABC/GCB and gene subtype"
rf_disc_ipi_abc_gene$directory = "rf/disc-ipi-abc-gene"
rf_disc_ipi_abc_gene$include_from_discrete_pheno = c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
    "n_extranodal_sites>1", "ann_arbor_stage>2", "gene_expression_subgroup", 
    "genetic_subtype")

rf_disc_ipi_gene = rf_disc_ipi_abc_gene$clone()
rf_disc_ipi_gene$name = "rf with disc IPI and gene subtype"
rf_disc_ipi_gene$directory = "rf/disc-ipi-gene"
rf_disc_ipi_gene$include_from_discrete_pheno = c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
    "n_extranodal_sites>1", "ann_arbor_stage>2", "genetic_subtype")

rf_cont_ipi = rf_disc_ipi$clone()
rf_cont_ipi$name = "rf with cont IPI"
rf_cont_ipi$directory = "rf/cont-ipi"
rf_cont_ipi$include_from_discrete_pheno = NULL
rf_cont_ipi$include_from_continuous_pheno = c("age", "ldh_ratio", "ecog_performance_status", 
    "n_extranodal_sites", "ann_arbor_stage")

rf_cont_ipi_abc = rf_cont_ipi$clone()
rf_cont_ipi_abc$name = "rf with cont IPI and ABC/GCB"
rf_cont_ipi_abc$directory = "rf/cont-ipi-abc"
rf_cont_ipi_abc$include_from_discrete_pheno = c("gene_expression_subgroup")

rf_cont_ipi_abc_gene = rf_cont_ipi_abc$clone()
rf_cont_ipi_abc_gene$name = "rf with cont IPI, ABC/GCB and gene subtype"
rf_cont_ipi_abc_gene$directory = "rf/cont-ipi-abc-gene"
rf_cont_ipi_abc_gene$include_from_discrete_pheno = c("gene_expression_subgroup", "genetic_subtype")

rf_cont_ipi_gene = rf_cont_ipi_abc_gene$clone()
rf_cont_ipi_gene$name = "rf with cont IPI and gene subtype"
rf_cont_ipi_gene$directory = "rf/cont-ipi-gene"
rf_cont_ipi_gene$include_from_discrete_pheno = c("genetic_subtype")

rf_ipi_score_cont_abc = rf_disc_ipi$clone()
rf_ipi_score_cont_abc$name = "rf with IPI score cont and ABC/GCB"
rf_ipi_score_cont_abc$directory = "rf/ipi-score-cont-abc"
rf_ipi_score_cont_abc$include_from_discrete_pheno = c("gene_expression_subgroup")
rf_ipi_score_cont_abc$include_from_continuous_pheno = c("ipi")
rf_ipi_score_cont_abc$hyperparams$mtry = 1:2

rf_ipi_score_cont_abc_gene = rf_ipi_score_cont_abc$clone()
rf_ipi_score_cont_abc_gene$name = "rf with IPI score cont, ABC/GCB and gene subtype"
rf_ipi_score_cont_abc_gene$directory = "rf/ipi-score-cont-abc-gene"
rf_ipi_score_cont_abc_gene$include_from_discrete_pheno = c("gene_expression_subgroup", "genetic_subtype")
rf_ipi_score_cont_abc_gene$hyperparams$mtry = 1:3

rf_ipi_score_cont_gene = rf_ipi_score_cont_abc$clone()
rf_ipi_score_cont_gene$name = "rf with IPI score cont and gene subtype"
rf_ipi_score_cont_gene$directory = "rf/ipi-score-cont-gene"
rf_ipi_score_cont_gene$include_from_discrete_pheno = c("genetic_subtype")

rf_ipi_group_abc = rf_disc_ipi$clone()
rf_ipi_group_abc$name = "rf with IPI group and ABC/GCB"
rf_ipi_group_abc$directory = "rf/ipi-group-abc"
rf_ipi_group_abc$include_from_discrete_pheno = c("ipi_group", "gene_expression_subgroup")

rf_ipi_group_abc_gene = rf_ipi_group_abc$clone()
rf_ipi_group_abc_gene$name = "rf with IPI group, ABC/GCB and gene subtype"
rf_ipi_group_abc_gene$directory = "rf/ipi-group-abc-gene"
rf_ipi_group_abc_gene$include_from_discrete_pheno = c("ipi_group", "gene_expression_subgroup", "genetic_subtype")

rf_ipi_group_gene = rf_ipi_group_abc_gene$clone()
rf_ipi_group_gene$name = "rf with IPI group and gene subtype"
rf_ipi_group_gene$directory = "rf/ipi-group-gene"
rf_ipi_group_gene$include_from_discrete_pheno = c("ipi_group", "genetic_subtype")

no_genomic <- list(
    rf_disc_ipi,
    rf_disc_ipi_abc,
    rf_disc_ipi_abc_gene,
    rf_disc_ipi_gene,
    rf_cont_ipi,
    rf_cont_ipi_abc,
    rf_cont_ipi_abc_gene,
    rf_cont_ipi_gene,
    rf_ipi_score_cont_abc,
    rf_ipi_score_cont_abc_gene,
    rf_ipi_score_cont_gene,
    rf_ipi_group_abc,
    rf_ipi_group_abc_gene,
    rf_ipi_group_gene
)

for(i in seq_along(no_genomic)) {
    model <- no_genomic[[i]]$clone()
    model$name <- stringr::str_replace(model$name, "^rf", "log")
    model$directory <- stringr::str_replace(model$directory, "^rf", 
        "logistic/3-early-int/nil")
    model$fitter <- ptk_zerosum
    model$hyperparams <- list(family = "binomial", alpha = 1, zeroSum = FALSE)
    no_genomic <- append(no_genomic, model)
}

models <- c(models, no_genomic)