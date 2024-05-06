# EARLY INTEGRATION

n_genes <- 25066

# ipi

# add discretized ipi features (as in paper)
# logistic
# ipi penalty = 0
lv_disc_ipi_feat = Model$new(
    name = "LV with disc IPI feat",
    fitter = zeroSum::zeroSum,
    directory = "logistic/3-early-int/vanilla-disc-ipi-feat",
    split_index = 1:5,
    time_cutoffs = c(1.75),
    hyperparams = list(family = "binomial", alpha = 1, zeroSum = FALSE, 
        penalty.factor = c(rep(1, n_genes), rep(0, 5))),
    include_from_discrete_pheno = c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
        "n_extranodal_sites>1", "ann_arbor_stage>2"),
    response_type = "binary"
)
# standardize
lv_disc_ipi_feat_std <- lv_disc_ipi_feat$clone()
lv_disc_ipi_feat_std$name <- "LV with disc IPI feat std"
lv_disc_ipi_feat_std$directory <- "logistic/3-early-int/vanilla-disc-ipi-feat-std"
lv_disc_ipi_feat_std$hyperparams$standardize <- TRUE
lv_disc_ipi_feat_std$hyperparams$penalty.factor <- NULL
# same for cox
# ipi penalty = 0
cv_disc_ipi_feat <- lv_disc_ipi_feat$clone()
cv_disc_ipi_feat$name <- "CV with disc IPI feat"
cv_disc_ipi_feat$directory <- "cox/3-early-int/vanilla-disc-ipi-feat"
cv_disc_ipi_feat$hyperparams$family <- "cox"
cv_disc_ipi_feat$response_type <- "survival_censored"
# standardize
cv_disc_ipi_feat_std <- lv_disc_ipi_feat_std$clone()
cv_disc_ipi_feat_std$name <- "CV with disc IPI feat std"
cv_disc_ipi_feat_std$directory <- "cox/3-early-int/vanilla-disc-ipi-feat-std"
cv_disc_ipi_feat_std$hyperparams$family <- "cox"
cv_disc_ipi_feat_std$response_type <- "survival_censored"

# add ipi as one continuous feature
# logistic
# ipi penalty = 0
lv_ipi_cont <- lv_disc_ipi_feat$clone()
lv_ipi_cont$name <- "LV with IPI cont"
lv_ipi_cont$directory <- "logistic/3-early-int/vanilla-ipi-cont"
lv_ipi_cont$hyperparams$penalty.factor <- c(rep(1, n_genes), 0)
lv_ipi_cont$include_from_continuous_pheno <- "ipi"
lv_ipi_cont$include_from_discrete_pheno <- NULL
# standardize
lv_ipi_cont_std <- lv_ipi_cont$clone()
lv_ipi_cont_std$name <- "LV with IPI cont std"
lv_ipi_cont_std$directory <- "logistic/3-early-int/vanilla-ipi-cont-std"
lv_ipi_cont_std$hyperparams$standardize <- TRUE
lv_ipi_cont_std$hyperparams$penalty.factor <- NULL
# same for cox
# ipi penalty = 0
cv_ipi_cont <- lv_ipi_cont$clone()
cv_ipi_cont$name <- "CV with IPI cont"
cv_ipi_cont$directory <- "cox/3-early-int/vanilla-ipi-cont"
cv_ipi_cont$hyperparams$family <- "cox"
cv_ipi_cont$response_type <- "survival_censored"
# standardize
cv_ipi_cont_std <- lv_ipi_cont_std$clone()
cv_ipi_cont_std$name <- "CV with IPI cont std"
cv_ipi_cont_std$directory <- "cox/3-early-int/vanilla-ipi-cont-std"
cv_ipi_cont_std$hyperparams$family <- "cox"
cv_ipi_cont_std$response_type <- "survival_censored"

# add ipi group as one discrete feature
# logistic
# ipi penalty = 0
lv_ipi_group <- lv_disc_ipi_feat$clone()
lv_ipi_group$name <- "LV with IPI group"
lv_ipi_group$directory <- "logistic/3-early-int/vanilla-ipi-group"
lv_ipi_group$hyperparams$penalty.factor <- c(rep(1, n_genes), rep(0, 2))
lv_ipi_group$include_from_discrete_pheno <- "ipi_group"
# standardize
lv_ipi_group_std <- lv_ipi_group$clone()
lv_ipi_group_std$name <- "LV with IPI group std"
lv_ipi_group_std$directory <- "logistic/3-early-int/vanilla-ipi-group-std"
lv_ipi_group_std$hyperparams$standardize <- TRUE
lv_ipi_group_std$hyperparams$penalty.factor <- NULL
# same for cox
# ipi penalty = 0
cv_ipi_group <- lv_ipi_group$clone()
cv_ipi_group$name <- "CV with IPI group"
cv_ipi_group$directory <- "cox/3-early-int/vanilla-ipi-group"
cv_ipi_group$hyperparams$family <- "cox"
cv_ipi_group$response_type <- "survival_censored"
# standardize
cv_ipi_group_std <- lv_ipi_group_std$clone()
cv_ipi_group_std$name <- "CV with IPI group std"
cv_ipi_group_std$directory <- "cox/3-early-int/vanilla-ipi-group-std"
cv_ipi_group_std$hyperparams$family <- "cox"
cv_ipi_group_std$response_type <- "survival_censored"

models <- list(
    lv_disc_ipi_feat = lv_disc_ipi_feat,
    lv_disc_ipi_feat_std = lv_disc_ipi_feat_std,
    cv_disc_ipi_feat = cv_disc_ipi_feat,
    cv_disc_ipi_feat_std = cv_disc_ipi_feat_std,
    lv_ipi_cont = lv_ipi_cont,
    lv_ipi_cont_std = lv_ipi_cont_std,
    cv_ipi_cont = cv_ipi_cont,
    cv_ipi_cont_std = cv_ipi_cont_std,
    lv_ipi_group = lv_ipi_group,
    lv_ipi_group_std = lv_ipi_group_std,
    cv_ipi_group = cv_ipi_group,
    cv_ipi_group_std = cv_ipi_group_std
)