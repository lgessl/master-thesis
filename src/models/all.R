# Models trained on Schmitz, Reddy, Lamis

# Basic (only expression data)

models <- list()

models[[1]] <- Model$new(
    name = "gauss zerosum",
    directory = "gauss/zerosum",
    fitter = ptk_zerosum,
    split_index = 1,
    time_cutoffs = seq(1, 2, 0.2),
    val_error_fun = neg_roc_auc,
    hyperparams = list(family = "gaussian", alpha = 1, zeroSum = TRUE),
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
    name = "log ei lamis score, ipi group, rest, no expr",
    fitter = ptk_zerosum,
    directory = "log/early-int/log-ei-lamis-score-ipi-group-rest-no-expr",
    split_index = 1,
    time_cutoffs = seq(1, 2, 0.2),
    val_error_fun = neg_roc_auc,
    hyperparams = list(family = "binomial", alpha = 1, zeroSum = FALSE, 
        standardize = TRUE, exclude_pheno_from_lasso = FALSE),
    include_expr = FALSE,
    include_from_continuous_pheno = "lamis_score",
    include_from_discrete_pheno = c("ipi_group", "gender", "gene_expression_subgroup"),
    combine_n_max_categorical_features = 1
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
    m$name <- stringr::str_replace(m$name, " no expr", "")
    m$directory <- stringr::str_replace(m$directory, "-no-expr", "")
    m$include_expr <- TRUE
    m$hyperparams[["zeroSum"]] <- TRUE
    m$hyperparams[["standardize"]] <- FALSE
    ei <- c(ei, m)
}

# Dito with combinations

for (m in ei) {
    m <- m$clone()
    m$name <- paste0(m$name, ", comb")
    m$directory <- paste0(m$directory, "-comb")
    m$combine_n_max_categorical_features <- 2:4
    ei <- c(ei, m)
}


# Late integration 

li <- list()

m0 <- Model$new(
    name = "cox-zerosum-cox lamis high+score, ipi group, rest",
    fitter = ptk_zerosum,
    directory = "cox/late-int/cox-zerosum-cox-lamis-high-score-ipi-group-rest",
    split_index = 1,
    time_cutoffs = c(seq(1.75, 2.25, 0.125), Inf),
    val_error_fun = neg_roc_auc,
    hyperparams = list(
        fitter1 = ptk_zerosum,
        fitter2 = ptk_zerosum,
        hyperparams1 = list(
            family = "cox",
            alpha = 1,
            zeroSum = TRUE,
            nFold = 10
        ),
        hyperparams2 = list(
            family = "cox",
            alpha = 1,
            zeroSum = FALSE,
            nFold = 10,
            standardize = TRUE,
            exclude_pheno_from_lasso = FALSE
        )
    ),
    include_from_continuous_pheno = "lamis_score",
    include_from_discrete_pheno = c("ipi_group", "gender", 
        "gene_expression_subgroup", "lamis_high"),
    combine_n_max_categorical_features = 1
)

li <- c(li, m0)

# Major lazer: light it up

models <- c(models, ei, li)
names(models) <- sapply(models, function(x) x$name)