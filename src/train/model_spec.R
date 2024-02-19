# General list of ModelSpec objects you can source into any script training models on a 
# certain data set

n_genes <- 25066

# BASIC models (only genomic data)

# COX
# vanilla
cox = ModelSpec(
    name = "cox vanilla zerosum",
    directory = "cox/0-vanilla/zerosum",
    fitter = zeroSum::zeroSum,
    split_index = 1:15, # 1:20
    time_cutoffs = c(seq(1, 2.5, .25), Inf), # seq(1.5, 2, .25)
    optional_fitter_args = list(family = "cox", alpha = 1, zeroSum = FALSE),
    response_type = "survival_censored"
)
cox_std = ModelSpec(
    name = "cox vanilla std",
    directory = "cox/0-vanilla/std",
    fitter = zeroSum::zeroSum,
    split_index = 1:15,
    time_cutoffs = c(seq(1, 2, .25), Inf),
    optional_fitter_args = list(family = "cox", alpha = 1, zeroSum = FALSE,
        standardize = TRUE),
    response_type = "survival_censored"
)
# zerosum
cox_zerosum = ModelSpec(
    name = "cox zerosum",
    fitter = zeroSum::zeroSum,
    directory = "cox/1-zerosum",
    split_index = 1:15,
    time_cutoffs = c(seq(1, 2, .25), Inf), # seq(1.5, 2, .25)
    optional_fitter_args = list(family = "cox", alpha = 1),
    response_type = "survival_censored"
)
# LOGISTIC
# vanilla
logistic = ModelSpec(
    name = "logistic vanilla zerosum",
    directory = "logistic/0-vanilla/zerosum",
    fitter = zeroSum::zeroSum,
    split_index = 1:15, # 1:20
    time_cutoffs = seq(1, 2, .25), # seq(1.5, 2, .25)
    optional_fitter_args = list(family = "binomial", alpha = 1, zeroSum = FALSE),
    response_type = "binary"
)
logistic_std = ModelSpec(
    name = "logistic vanilla std",
    directory = "logistic/0-vanilla/std",
    fitter = zeroSum::zeroSum,
    split_index = 1:15,
    time_cutoffs = seq(1, 2, .25),
    optional_fitter_args = list(family = "binomial", alpha = 1, zeroSum = FALSE,
        standardize = TRUE),
    response_type = "binary"
)
# zerosum
logistic_zerosum = ModelSpec(
    name = "logistic zerosum",
    directory = "logistic/1-zerosum",
    fitter = glmnet::cv.glmnet,
    split_index = 1:15,
    time_cutoffs = seq(1, 2, .25), # seq(1.5, 2, .25)
    optional_fitter_args = list(family = "binomial", alpha = 1),
    response_type = "binary"
)

basic_msl <- list(
    # COX
    # vanilla
    cox = cox,
    cox_std = cox_std,
    # zerosum
    cox_zerosum = cox_zerosum,
    # LOGISTIC
    # vanilla
    logistic = logistic,
    logistic_std = logistic_std,
    # zerosum
    logistic_zerosum = logistic_zerosum
)


# EARLY INTEGRATION

# ipi

# add discretized ipi features (as in paper)
# logistic
# ipi penalty = 0
lv_disc_ipi_feat = ModelSpec(
    name = "LV with disc IPI feat",
    fitter = zeroSum::zeroSum,
    directory = "logistic/3-early-int/vanilla-disc-ipi-feat",
    split_index = 1:5,
    time_cutoffs = c(1.5, 1.75),
    optional_fitter_args = list(family = "binomial", alpha = 1, zeroSum = FALSE, 
        penalty.factor = c(rep(1, n_genes), rep(0, 5))),
    include_from_discrete_pheno = c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
        "n_extranodal_sites>1", "ann_arbor_stage>2"),
    response_type = "binary"
)
# standardize
lv_disc_ipi_feat_std <- lv_disc_ipi_feat
lv_disc_ipi_feat_std$name <- "LV with disc IPI feat std"
lv_disc_ipi_feat_std$directory <- "logistic/3-early-int/vanilla-disc-ipi-feat-std"
lv_disc_ipi_feat_std$optional_fitter_args$standardize <- TRUE
lv_disc_ipi_feat_std$optional_fitter_args$penalty.factor <- NULL
# same for cox
# ipi penalty = 0
cv_disc_ipi_feat <- lv_disc_ipi_feat
cv_disc_ipi_feat$name <- "CV with disc IPI feat"
cv_disc_ipi_feat$directory <- "cox/3-early-int/vanilla-disc-ipi-feat"
cv_disc_ipi_feat$optional_fitter_args$family <- "cox"
cv_disc_ipi_feat$response_type <- "survival_censored"
# standardize
cv_disc_ipi_feat_std <- lv_disc_ipi_feat_std
cv_disc_ipi_feat_std$name <- "CV with disc IPI feat std"
cv_disc_ipi_feat_std$directory <- "cox/3-early-int/vanilla-disc-ipi-feat-std"
cv_disc_ipi_feat_std$optional_fitter_args$family <- "cox"
cv_disc_ipi_feat_std$response_type <- "survival_censored"

# add ipi as one continuous feature
# logistic
# ipi penalty = 0
lv_ipi_cont <- lv_disc_ipi_feat
lv_ipi_cont$name <- "LV with IPI cont"
lv_ipi_cont$directory <- "logistic/3-early-int/vanilla-ipi-cont"
lv_ipi_cont$optional_fitter_args$penalty.factor <- c(rep(1, n_genes), 0)
lv_ipi_cont$include_from_continuous_pheno <- "ipi"
lv_ipi_cont$include_from_discrete_pheno <- NULL
# standardize
lv_ipi_cont_std <- lv_ipi_cont
lv_ipi_cont_std$name <- "LV with IPI cont std"
lv_ipi_cont_std$directory <- "logistic/3-early-int/vanilla-ipi-cont-std"
lv_ipi_cont_std$optional_fitter_args$standardize <- TRUE
lv_ipi_cont_std$optional_fitter_args$penalty.factor <- NULL
# same for cox
# ipi penalty = 0
cv_ipi_cont <- lv_ipi_cont
cv_ipi_cont$name <- "CV with IPI cont"
cv_ipi_cont$directory <- "cox/3-early-int/vanilla-ipi-cont"
cv_ipi_cont$optional_fitter_args$family <- "cox"
cv_ipi_cont$response_type <- "survival_censored"
# standardize
cv_ipi_cont_std <- lv_ipi_cont_std
cv_ipi_cont_std$name <- "CV with IPI cont std"
cv_ipi_cont_std$directory <- "cox/3-early-int/vanilla-ipi-cont-std"
cv_ipi_cont_std$optional_fitter_args$family <- "cox"
cv_ipi_cont_std$response_type <- "survival_censored"

ei_msl <- list(
    lv_disc_ipi_feat = lv_disc_ipi_feat,
    lv_disc_ipi_feat_std = lv_disc_ipi_feat_std,
    cv_disc_ipi_feat = cv_disc_ipi_feat,
    cv_disc_ipi_feat_std = cv_disc_ipi_feat_std,
    lv_ipi_cont = lv_ipi_cont,
    lv_ipi_cont_std = lv_ipi_cont_std,
    cv_ipi_cont = cv_ipi_cont,
    cv_ipi_cont_std = cv_ipi_cont_std
)
