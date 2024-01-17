# General list of ModelSpec objects you can source into any script training models on a 
# certain data set

# HOPEFULS

# COX
# vanilla
cox_vanilla_zerosum = ModelSpec(
    name = "cox vanilla zerosum",
    directory = "cox/0-vanilla/zerosum",
    fitter = zeroSum::zeroSum,
    split_index = 1:20,
    time_cutoffs = seq(1, 2, .25),
    optional_fitter_args = list(family = "cox", alpha = 1, zeroSum = FALSE),
    response_type = "survival_censored"
)
cox_vanilla_glmnet = ModelSpec(
    name = "cox vanilla glmnet",
    directory = "cox/0-vanilla/glmnet",
    fitter = glmnet::cv.glmnet,
    split_index = 1:5,
    time_cutoffs = seq(1.5, 2, .25),
    optional_fitter_args = list(family = "cox", alpha = 1),
    response_type = "survival_censored"
)
# zerosum
cox_zerosum = ModelSpec(
    name = "cox zerosum",
    fitter = zeroSum::zeroSum,
    directory = "cox/1-zerosum",
    split_index = 1:5,
    time_cutoffs = seq(1.5, 2, .25),
    optional_fitter_args = list(family = "cox", alpha = 1),
    response_type = "survival_censored"
)
# LOGISTIC
# vanilla
logistic_vanilla_zerosum = ModelSpec(
    name = "logistic vanilla zerosum",
    directory = "logistic/0-vanilla/zerosum",
    fitter = zeroSum::zeroSum,
    split_index = 1:20,
    time_cutoffs = seq(1, 2, .25),
    optional_fitter_args = list(family = "binomial", alpha = 1, zeroSum = FALSE),
    response_type = "binary"
)
logistic_vanilla_glmnet = ModelSpec(
    name = "logistic vanilla glmnet",
    directory = "logistic/0-vanilla/glmnet",
    fitter = zeroSum::zeroSum,
    split_index = 1:5,
    time_cutoffs = seq(1.5, 2, .25),
    optional_fitter_args = list(family = "binomial", alpha = 1),
    response_type = "binary"
)
# zerosum
logistic_zerosum = ModelSpec(
    name = "logistic zerosum",
    directory = "logistic/1-zerosum",
    fitter = zeroSum::zeroSum,
    split_index = 1:5,
    time_cutoffs = seq(1.5, 2, .25),
    optional_fitter_args = list(family = "binomial", alpha = 1),
    response_type = "binary"
)

model_spec_list <- list(
    # COX
    # vanilla
    cox_vanilla_zerosum,
    # cox_vanilla_glmnet,
    # # zerosum
    cox_zerosum,
    # # LOGISTIC
    # # vanilla
    logistic_vanilla_zerosum,
    # logistic_vanilla_glmnet,
    logistic_zerosum
    # logistic_zerosum
)


# RETIRED

# early IPI integration
# discretized IPI features (as in paper)
clz_disc_ipi_feat = ModelSpec(
    name = "CLZ with disc IPI feat",
    directory = "cox/early-int/clz-disc-ipi-feat",
    fitter = zeroSumWithPheno,
    split_index = 1,
    time_cutoffs = 2.,
    optional_fitter_args = list(family = "cox", alpha = 1),
    include_from_discrete_pheno = c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
        "n_extranodal_sites>1", "ann_arbor_stage>2"),
    response_type = "survival_censored"
)
llz_disc_ipi_feat = ModelSpec(
    name = "LLZ with disc IPI feat",
    fitter = zeroSumWithPheno,
    directory = "logistic/3-early-int/llz-disc-ipi-feat",
    split_index = 1,
    time_cutoffs = 2.,
    optional_fitter_args = list(family = "binomial", alpha = 1),
    include_from_discrete_pheno = c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
        "n_extranodal_sites>1", "ann_arbor_stage>2"),
    response_type = "binary"
)
# just IPI as one feature
clz_ipi = ModelSpec(
    name = "CLZ with IPI",
    fitter = zeroSumWithPheno,
    directory = "cox/3-early-int/clz-ipi",
    split_index = 1,
    time_cutoffs = 2.,
    optional_fitter_args = list(family = "cox", alpha = 1),
    include_from_discrete_pheno = c("ipi"),
    response_type = "survival_censored"
)
llz_ipi = ModelSpec(
    name = "LLZ with IPI",
    fitter = zeroSumWithPheno,
    directory = "logistic/3-early-int/llz-ipi",
    split_index = 1,
    time_cutoffs = 2.,
    optional_fitter_args = list(family = "binomial", alpha = 1),
    include_from_discrete_pheno = c("ipi"),
    response_type = "binary"
)
# continuous IPI features
clz_cont_ipi_features = ModelSpec(
    name = "CLZ with cont IPI feat",
    fitter = zeroSumWithPheno,
    directory = "cox/3-early-int/clz-cont-ipi-features",
    split_index = 1,
    time_cutoffs = 2.,
    optional_fitter_args = list(family = "cox", alpha = 1),
    include_from_continuous_pheno = c("age", "ldh_ratio", "ecog_performance_status", 
        "n_extranodal_sites", "ann_arbor_stage"),
    response_type = "survival_censored"
)
llz_cont_ipi_features = ModelSpec(
    name = "LLZ with cont IPI feat",
    directory = "logistic/3-early-int/llz-cont-ipi-features",
    fitter = zeroSumWithPheno,
    split_index = 1,
    time_cutoffs = 2.,
    optional_fitter_args = list(family = "binomial", alpha = 1),
    include_from_continuous_pheno = c("age", "ldh_ratio", "ecog_performance_status", 
        "n_extranodal_sites", "ann_arbor_stage"),
    response_type = "binary"
)
# just IPI group as one feature
clz_ipi_group = ModelSpec(
    name = "CLZ with IPI group",
    directory = "cox/3-early-int/clz-ipi-group",
    fitter = zeroSumWithPheno,
    split_index = 1,
    time_cutoffs = 2.,
    optional_fitter_args = list(family = "cox", alpha = 1),
    include_from_discrete_pheno = c("ipi_group"),
    response_type = "survival_censored"
)
llz_ipi_group = ModelSpec(
    name = "LLZ with IPI group",
    directory = "logistic/3-early-int/llz-ipi-group",
    fitter = zeroSumWithPheno,
    split_index = 1,
    time_cutoffs = 2.,
    optional_fitter_args = list(family = "binomial", alpha = 1),
    include_from_discrete_pheno = c("ipi_group"),
    response_type = "binary"
)

retired_models <- list(
    # early IPI integration
    # discretized IPI features (as in paper)
    clz_disc_ipi_feat,
    llz_disc_ipi_feat,
    # just IPI as one feature
    clz_ipi,
    llz_ipi,
    # continuous IPI features
    clz_cont_ipi_features,
    llz_cont_ipi_features,
    # just IPI group as one feature
    clz_ipi_group,
    llz_ipi_group
)