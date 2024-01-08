# General list of ModelSpec objects you can source into any script training models on a 
# certain data set

model_spec_list <- list(
    # hopefuls
    cox_lasso_zerosum = ModelSpec(
        name = "Cox LASSO zeroSum",
        fitter = zeroSum::zeroSum,
        optional_fitter_args = list(family = "cox", alpha = 1),
        response_type = "survival_censored",
        save_dir = "cox/1-zerosum/2-0"
    ),
    cox_lasso = ModelSpec(
        name = "Cox LASSO",
        fitter = zeroSum::zeroSum,
        optional_fitter_args = list(family = "cox", alpha = 1, zeroSum = FALSE),
        response_type = "survival_censored",
        save_dir = "cox/0-vanilla/2-0"
    ),
    logistic_lasso_zerosum = ModelSpec(
        name = "Logistic LASSO zeroSum",
        fitter = zeroSum::zeroSum,
        optional_fitter_args = list(family = "binomial", alpha = 1),
        response_type = "binary",
        save_dir = "logistic/1-zerosum/2-0"
    ),
    logistic_lasso = ModelSpec(
        name = "Logistic LASSO",
        fitter = zeroSum::zeroSum,
        optional_fitter_args = list(family = "binomial", alpha = 1, zeroSum = FALSE),
        response_type = "binary",
        save_dir = "logistic/0-vanilla/2-0"
    )
)

retired_models <- list(
    clz_disc_ipi_feat = ModelSpec(
        name = "CLZ with disc IPI feat",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "cox", alpha = 1),
        include_from_discrete_pheno = c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
            "n_extranodal_sites>1", "ann_arbor_stage>2"),
        response_type = "survival_censored",
        save_dir = "cox/early-int/clz-disc-ipi-feat"
    ),
    llz_disc_ipi_feat = ModelSpec(
        name = "LLZ with disc IPI feat",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "binomial", alpha = 1),
        include_from_discrete_pheno = c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
            "n_extranodal_sites>1", "ann_arbor_stage>2"),
        response_type = "binary",
        save_dir = "logistic/3-early-int/llz-disc-ipi-feat"
    ),
    clz_ipi = ModelSpec(
        name = "CLZ with IPI",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "cox", alpha = 1),
        include_from_discrete_pheno = c("ipi"),
        response_type = "survival_censored",
        save_dir = "cox/3-early-int/clz-ipi"
    ),
    llz_ipi = ModelSpec(
        name = "LLZ with IPI",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "binomial", alpha = 1),
        include_from_discrete_pheno = c("ipi"),
        response_type = "binary",
        save_dir = "logistic/3-early-int/llz-ipi"
    ),
    clz_cont_ipi_features = ModelSpec(
        name = "CLZ with cont IPI feat",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "cox", alpha = 1),
        include_from_continuous_pheno = c("age", "ldh_ratio", "ecog_performance_status", 
            "n_extranodal_sites", "ann_arbor_stage"),
        response_type = "survival_censored",
        save_dir = "cox/3-early-int/clz-cont-ipi-features"
    ),
    llz_cont_ipi_features = ModelSpec(
        name = "LLZ with cont IPI feat",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "binomial", alpha = 1),
        include_from_continuous_pheno = c("age", "ldh_ratio", "ecog_performance_status", 
            "n_extranodal_sites", "ann_arbor_stage"),
        response_type = "binary",
        save_dir = "logistic/3-early-int/llz-cont-ipi-features"
    ),
    clz_ipi_group = ModelSpec(
        name = "CLZ with IPI group",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "cox", alpha = 1),
        include_from_discrete_pheno = c("ipi_group"),
        response_type = "survival_censored",
        save_dir = "cox/3-early-int/clz-ipi-group"
    ),
    llz_ipi_group = ModelSpec(
        name = "LLZ with IPI group",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "binomial", alpha = 1),
        include_from_discrete_pheno = c("ipi_group"),
        response_type = "binary",
        save_dir = "logistic/3-early-int/llz-ipi-group"
    )
)