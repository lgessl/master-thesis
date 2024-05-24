# EARLY INTEGRATION

# ipi

# add discretized ipi features (as in paper)
# logistic
# ipi penalty = 0
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
    response_type = "binary"
)
models <- list(log_disc_ipi)

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
    models <- append(models, model)
}
for (i in seq_along(models)) {
    model_std <- models[[i]]$clone()
    model_std$name <- paste0(model_std$name, " std")
    model_std$directory <- paste0(model_std$directory, "-std")
    model_std$hyperparams$standardize <- TRUE
    model_std$hyperparams$exclude_pheno_from_lasso <- FALSE
    models <- append(models, model_std)
}
# Same for Cox
for (i in seq_along(models)) {
    model <- models[[i]]$clone()
    model$name <- stringr::str_replace(model$name, "log", "cox")
    model$directory <- stringr::str_replace(model$directory, "logistic", 
        "cox")
    model$hyperparams[["family"]] <- "cox"
    model$response_type <- "survival_censored"
    models <- append(models, model)
}

# No more cox, no more standardization (they suck)
model_names <- sapply(models, function(x) x$name)
hopeful_names <- c(
    "ei log with disc IPI", 
    "ei log with cont IPI", 
    "ei log with IPI score continuous", 
    "ei log with IPI group"
)
hopefuls <- models[model_names %in% hopeful_names]
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
    name = "rf no expr with disc IPI",
    directory = "rf/disc-ipi",
    fitter = ptk_ranger,
    split_index = 1:5,
    time_cutoffs = c(1.75),
    hyperparams = list(
        num.trees = 600, 
        mtry = NULL,
        min.node.size = 1,
        classification = TRUE,
        skip_on_invalid_input = TRUE
    ),
    response_type = "binary",
    include_from_discrete_pheno = c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
        "n_extranodal_sites>1", "ann_arbor_stage>2"),
    include_expr = FALSE
)
no_expr <- list(rf_disc_ipi)

for (i in seq_along(names)) { # expand to other base features
    model <- rf_disc_ipi$clone()
    model$name <- stringr::str_replace(model$name, "disc IPI", names[i])
    model$directory <- stringr::str_replace(model$directory, "disc-ipi", 
        directories[i])
    model$include_from_discrete_pheno <- include_discrete[[i]]
    model$include_from_continuous_pheno <- include_continuous[[i]]
    no_expr <- append(no_expr, model)
}
for(i in seq_along(no_expr)) {
    for (j in seq_along(append_to_name)) { # add more features
        model <- no_expr[[i]]$clone()
        model$name <- paste0(model$name, ", ", append_to_name[j])
        model$directory <- paste0(model$directory, "-", append_to_directory[j])
        model$include_from_discrete_pheno <- c(model$include_from_discrete_pheno, append_to_disc_feat[[j]])
        no_expr <- append(no_expr, model)
    }
}
for(i in seq_along(no_expr)) { # logistic instead of rf
    model <- no_expr[[i]]$clone()
    model$name <- stringr::str_replace(model$name, "^rf", "log")
    model$directory <- stringr::str_replace(model$directory, "^rf", 
        "logistic/3-early-int/nil")
    model$fitter <- ptk_zerosum
    model$hyperparams <- list(family = "binomial", lambda = 0, zeroSum = FALSE)
    no_expr <- append(no_expr, model)
}

models <- c(models, no_expr)
the_best <- list()
for(model in models){
    # Other data sets don't include gene subtype
    if(!stringr::str_detect(model$name, "gene subtype")){
        the_best <- c(the_best, model)
    }
}
