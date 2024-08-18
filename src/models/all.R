# Models trained on Schmitz, Reddy, Lamis

library(patroklos)

# Basic (only expression data)

models <- list()

models[[1]] <- Model$new(
    name = "gauss zerosum",
    directory = "gauss/zerosum",
    fitter = ptk_zerosum,
    time_cutoffs = seq(1, 2.6, 0.2),
    val_error_fun = neg_prec_with_prev_greater(0.17),
    hyperparams = list(family = "gaussian", alpha = 1, zeroSum = TRUE, nFold = 1000),
)

m <- models[[1]]$clone()
m$name <- "log zerosum"
m$directory <- "log/zerosum"
m$hyperparams[["family"]] <- "binomial"
models <- c(models, m)

m <- models[[1]]$clone()
m$name <- "cox zerosum"
m$directory <- "cox/zerosum"
m$time_cutoffs <- c(m$time_cutoffs, Inf)
m$hyperparams[["family"]] <- "cox"
models <- c(models, m)

# Early integration of LAMIS signature

ei <- list()

m0 <- Model$new(
    name = "log ei lamis score, rest, no expr",
    fitter = ptk_zerosum,
    directory = "log/early-int/log-ei-lamis-score-rest-no-expr",
    time_cutoffs = seq(1.4, 2, 0.2),
    val_error_fun = neg_prec_with_prev_greater(0.17),
    hyperparams = list(family = "binomial", alpha = 1, zeroSum = FALSE, 
        standardize = TRUE, exclude_pheno_from_lasso = FALSE, nFold = 1000),
    include_expr = FALSE,
    include_from_continuous_pheno = "lamis_score",
    include_from_discrete_pheno = c("ipi_group", "gender", "gene_expression_subgroup",
        "age>60", "ldh_ratio>1", "ecog_performance_status>1", 
        "n_extranodal_sites>1", "ann_arbor_stage>2"),
    combine_n_max_categorical_features = 1:3
)
ei <- c(ei, m0)

m <- m0$clone()
m$name <- stringr::str_replace(m$name, "lamis score", "lamis high")
m$directory <- stringr::str_replace(m$directory, "lamis-score", "lamis-high")
m$include_from_discrete_pheno <- c(m$include_from_discrete_pheno, "lamis_high")
m$include_from_continuous_pheno <- NULL
ei <- c(ei, m)

m <- m0$clone()
m$name <- stringr::str_replace(m$name, "lamis score", "lamis high+score")
m$directory <- stringr::str_replace(m$directory, "lamis-score", "lamis-high-score")
m$include_from_discrete_pheno <- c(m$include_from_discrete_pheno, "lamis_high")
ei <- c(ei, m)

# Dito for Cox

for (m in ei) {
    m <- m$clone()
    m$name <- stringr::str_replace_all(m$name, "log", "cox")
    m$directory <- stringr::str_replace_all(m$directory, "log", "cox")
    m$time_cutoffs <- c(m$time_cutoffs, Inf)
    m$hyperparams[["family"]] <- "cox"
    ei <- c(ei, m)
}

# Dito with expression

for (m in ei) {
    m <- m$clone()
    m$name <- stringr::str_replace(m$name, ", no expr", "")
    m$directory <- stringr::str_replace(m$directory, "-no-expr", "")
    m$include_expr <- TRUE
    m$hyperparams[["zeroSum"]] <- TRUE
    m$hyperparams[["standardize"]] <- FALSE
    ei <- c(ei, m)
}

# rf on lamis high, without expression
rf <- Model$new(
    name = "rf lamis high, rest, no expr",
    directory = "rf/early-int/rf-lamis-high-rest-no-expr",
    fitter = multitune(ptk_ranger, select = TRUE),
    time_cutoffs = seq(1.4, 2.2, 0.2),
    val_error_fun = neg_prec_with_prev_greater(0.17),
    hyperparams = list(
        num.trees = 1000,
        min.node.size = 1:5,
        mtry = seq(0.8, 1.2, 0.04),
        rel_mtry = TRUE,
        classification = TRUE,
        skip_on_invalid_input = TRUE
    ),
    include_from_continuous_pheno = NULL,
    include_from_discrete_pheno = c("ipi_group", "gender", "gene_expression_subgroup",
        "age>60", "ldh_ratio>1", "ecog_performance_status>1", 
        "n_extranodal_sites>1", "ann_arbor_stage>2", "lamis_high"),
    combine_n_max_categorical_features = 1
)
ei <- c(ei, rf)

# No late integration: overfitting on validated predictions

models <- c(models, ei)

# IPI
ipi <- Model$new(
    name = "ipi",
    directory = "ipi",
    fitter = projection_on_feature,
    time_cutoffs = 2,
    val_error_fun = neg_prec_with_prev_greater(0.17),
    hyperparams = list(feature = "ipi"),
    include_from_continuous_pheno = "ipi",
    include_from_discrete_pheno = NULL,
    include_expr = FALSE,
    enable_imputation = FALSE
)
models <- c(models, ipi)

# Major lazer: light it up

names(models) <- sapply(models, function(x) x$name)