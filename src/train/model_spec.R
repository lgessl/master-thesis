# General list of ModelSpec objects you can source into any script training models on a 
# certain data set

model_spec_list <- list(
    # hopefuls
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
    clz_disc_ipi_feat = ModelSpec(
        name = "CLZ with disc IPI feat",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "cox", alpha = 1),
        include_from_discrete_pheno = c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
            "n_extranodal_sites>1", "ann_arbor_stage>2"),
        response_type = "survival_censored",
        save_dir = "clz-disc-ipi-feat"
    ),
    blz_disc_ipi_feat = ModelSpec(
        name = "BLZ with disc IPI feat",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "binomial", alpha = 1),
        include_from_discrete_pheno = c("age>60", "ldh_ratio>1", "ecog_performance_status>1", 
            "n_extranodal_sites>1", "ann_arbor_stage>2"),
        response_type = "binary",
        save_dir = "blz-disc-ipi-feat"
    ),
    # retired models
    clz_ipi = ModelSpec(
        name = "CLZ with IPI",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "cox", alpha = 1),
        include_from_discrete_pheno = c("ipi"),
        response_type = "survival_censored",
        save_dir = "clz-ipi"
    ),
    blz_ipi = ModelSpec(
        name = "BLZ with IPI",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "binomial", alpha = 1),
        include_from_discrete_pheno = c("ipi"),
        response_type = "binary",
        save_dir = "blz-ipi"
    ),
    clz_cont_ipi_features = ModelSpec(
        name = "CLZ with cont IPI feat",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "cox", alpha = 1),
        include_from_continuous_pheno = c("age", "ldh_ratio", "ecog_performance_status", 
            "n_extranodal_sites", "ann_arbor_stage"),
        response_type = "survival_censored",
        save_dir = "clz-cont-ipi-features"
    ),
    blz_cont_ipi_features = ModelSpec(
        name = "BLZ with cont IPI feat",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "binomial", alpha = 1),
        include_from_continuous_pheno = c("age", "ldh_ratio", "ecog_performance_status", 
            "n_extranodal_sites", "ann_arbor_stage"),
        response_type = "binary",
        save_dir = "blz-cont-ipi-features"
    ),
    clz_ipi_group = ModelSpec(
        name = "CLZ with IPI group",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "cox", alpha = 1),
        include_from_discrete_pheno = c("ipi_group"),
        response_type = "survival_censored",
        save_dir = "clz-ipi-group"
    ),
    blz_ipi_group = ModelSpec(
        name = "BLZ with IPI group",
        fitter = zeroSumWithPheno,
        optional_fitter_args = list(family = "binomial", alpha = 1),
        include_from_discrete_pheno = c("ipi_group"),
        response_type = "binary",
        save_dir = "blz-ipi-group"
    ),
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