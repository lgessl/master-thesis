# General list of ModelSpec objects you can source into any script training models on a 
# certain data set

model_spec_list <- list(
    # hopfuls
    cox_lasso_zerosum = ModelSpec(
        name = "Cox LASSO zeroSum",
        fitter = zeroSum::zeroSum,
        optional_fitter_args = list(family = "cox", alpha = 1),
        response_type = "survival_censored",
        save_dir = "cox-lasso-zerosum"
    ),
    binomial_lasso_zerosum = ModelSpec(
        name = "Binomial LASSO zeroSum",
        fitter = zeroSum::zeroSum,
        optional_fitter_args = list(family = "binomial", alpha = 1),
        response_type = "binary",
        save_dir = "binomial-lasso-zerosum"
    ),
    clz_with_cont_ipi_features = ModelSpec(
        name = "CLZ with cont IPI feat",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "cox", alpha = 1),
        include_from_continuous_pheno = c("age", "ldh_ratio", "ecog_performance_status", 
            "number_of_extranodal_sites", "ann_arbor_stage"),
        response_type = "survival_censored",
        save_dir = "clz-with-cont-ipi-features"
    ),
    blz_with_cont_ipi_features = ModelSpec(
        name = "BLZ with cont IPI feat",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "binomial", alpha = 1),
        include_from_continuous_pheno = c("age", "ldh_ratio", "ecog_performance_status", 
            "number_of_extranodal_sites", "ann_arbor_stage"),
        response_type = "binary",
        save_dir = "blz-with-cont-ipi-features"
    ),
    clz_with_ipi = ModelSpec(
        name = "CLZ with IPI",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "cox", alpha = 1),
        include_from_discrete_pheno = c("ipi"),
        response_type = "survival_censored",
        save_dir = "clz-with-ipi"
    ),
    blz_with_ipi = ModelSpec(
        name = "BLZ with IPI",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "binomial", alpha = 1),
        include_from_discrete_pheno = c("ipi"),
        response_type = "binary",
        save_dir = "blz-with-ipi"
    ),
    clz_with_ipi_group = ModelSpec(
        name = "CLZ with IPI group",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "cox", alpha = 1),
        include_from_discrete_pheno = c("ipi_group"),
        response_type = "survival_censored",
        save_dir = "clz-with-ipi-group"
    ),
    blz_with_ipi_group = ModelSpec(
        name = "BLZ with IPI group",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "binomial", alpha = 1),
        include_from_discrete_pheno = c("ipi_group"),
        response_type = "binary",
        save_dir = "blz-with-ipi-group"
    ),
    # retired models
    cox_lasso = ModelSpec(
        name = "Cox LASSO",
        fitter = zeroSum::zeroSum,
        optional_fitter_args = list(family = "cox", alpha = 1, zeroSum = FALSE),
        response_type = "survival_censored",
        save_dir = "cox-lasso"
    ),
    binomial_lasso = ModelSpec(
        name = "Binomial LASSO",
        fitter = zeroSum::zeroSum,
        optional_fitter_args = list(family = "binomial", alpha = 1, zeroSum = FALSE),
        response_type = "binary",
        save_dir = "binomial-lasso"
    )
)