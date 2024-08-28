# Assess models on combined big data set
# For every train cohort (Schmitz, Reddy, Staiger), denoted <train cohort>, 
# - assess the models trained <train cohort> on <train cohort> according to their validated 
#   predictions (-> results/all/<train cohort>_val.csv),
# - pick the model with minimal validation error,
# - assess it on the two remaining cohorts as test sets, denoted <test cohort>, 
#   (-> results/all/<train cohort>_on_<test cohort>.csv)

library(patroklos)

source("src/assess/config.R")

data <- readRDS("data/all/data.rds")

# Trained on Staiger
source("src/models/all.R")
prepend_to_directory(models, "models/all/on_staiger")
data$cohort <- "val_predict"
pan_ass_scalar$file <- "results/all/staiger_val.csv"
val_tbl <- pan_ass_scalar$assess_center(data, models)
data$cohort <- "schmitz"
models <- models[c(val_tbl[["model"]][1], "ipi")]

# Assess this model on schmitz
data$cohort <- "schmitz"
pan_ass_scalar$file <- "results/all/staiger_on_schmitz.csv"
pan_ass_scalar$assess_center(data, models)

# Assess this model on reddy
data$cohort <- "reddy"
pan_ass_scalar$file <- "results/all/staiger_on_reddy.csv"
pan_ass_scalar$assess_center(data, models)

# Trained on schmitz
source("src/models/all.R")
prepend_to_directory(models, "models/all/on_schmitz")
data$cohort <- "val_predict"
pan_ass_scalar$file <- "results/all/schmitz_val.csv"
val_tbl <- pan_ass_scalar$assess_center(data, models)
models <- models[c(val_tbl[["model"]][1], "ipi")]

# Assess this model on the Staiger
data$cohort <- "staiger"
pan_ass_scalar$file <- "results/all/schmitz_on_staiger.csv"
pan_ass_scalar$assess_center(data, models)

# Assess this model on reddy
data$cohort <- "reddy"
pan_ass_scalar$file <- "results/all/schmitz_on_reddy.csv"
pan_ass_scalar$assess_center(data, models)

# Trained on reddy
source("src/models/all.R")
prepend_to_directory(models, "models/all/on_reddy")
data$cohort <- "val_predict"
pan_ass_scalar$file <- "results/all/reddy_val.csv"
val_tbl <- pan_ass_scalar$assess_center(data, models)
data$cohort <- "staiger"
models <- models[c(val_tbl[["model"]][1], "ipi")]

# Assess this model on the Staiger
data$cohort <- "staiger"
pan_ass_scalar$file <- "results/all/reddy_on_staiger.csv"
pan_ass_scalar$assess_center(data, models)

# Assess this model on schmitz
data$cohort <- "schmitz"
pan_ass_scalar$file <- "results/all/reddy_on_schmitz.csv"
pan_ass_scalar$assess_center(data, models)