# Report the features the best validated models use

library(patroklos)
library(stringr)

# Intra trial
cat(str_pad(" Intra-trial experiments ", width = 100, "both", pad = "*"), "\n\n")

# Schmitz
cat(str_pad("Schmitz ", width = 100, "right", pad = "*"), "\n\n")
data <- readRDS("data/schmitz/data.rds")$read()
model <- readRDS("models/schmitz/gauss/2-late-int/gauss-cox-all-ipi/model.rds")
print(non_zero_coefs(model$fit_obj))   
cat("\nn_combi:", model$fit_obj$combine_n_max_categorical_features, "\n")
cat("T:", model$fit_obj$time_cutoff, "\n\n")

# Reddy
cat(str_pad("Reddy ", width = 100, "right", pad = "*"), "\n\n")
data <- readRDS("data/reddy/data.rds")$read()
model <- readRDS("models/reddy/gauss/late-int/gauss-cox-disc-ipi-rest/model.rds")
print(non_zero_coefs(model$fit_obj))
cat("\nn_combi:", model$fit_obj$combine_n_max_categorical_features, "\n")
cat("T:", model$fit_obj$time_cutoff, "\n\n")

# Lamis test
cat(str_pad("Lamis test ", width = 100, "right", pad = "*"), "\n\n")
data <- readRDS("data/lamis_test2/data.rds")$read()
model <- readRDS("models/lamis_test2/log/early-int/log-ei-all-ipi-no-expr/model.rds")
print(non_zero_coefs(model$fit_obj))
cat("\nn_combi:", model$fit_obj$combine_n_max_categorical_features, "\n")
cat("T:", model$fit_obj$time_cutoff, "\n\n\n")

# Inter trial
cat(str_pad("Inter-trial experiments", width = 100, "both", pad = "*"), "\n\n")
data <- readRDS("data/all/data.rds")

# Trained on Schmitz
cat(str_pad("Trained on Schmitz ", width = 100, "right", pad = "*"), "\n\n")
model <- readRDS("models/all/on_schmitz/cox/early-int/cox-ei-lamis-high-rest-no-expr/model.rds")
print(non_zero_coefs(model$fit_obj))
cat("\nn_combi:", model$fit_obj$combine_n_max_categorical_features, "\n")
cat("T:", model$fit_obj$time_cutoff, "\n\n")

# Trained on Reddy
cat(str_pad("Trained on Reddy ", width = 100, "right", pad = "*"), "\n\n")
model <- readRDS("models/all/on_reddy/log/early-int/log-ei-lamis-score-rest-no-expr/model.rds")
print(non_zero_coefs(model$fit_obj))
cat("\nn_combi:", model$fit_obj$combine_n_max_categorical_features, "\n")
cat("T:", model$fit_obj$time_cutoff, "\n\n")

# Trained on Lamis test
cat(str_pad("Trained on Lamis test ", width = 100, "right", pad = "*"), "\n\n")
model <- readRDS("models/all/on_lamis/cox/early-int/cox-ei-lamis-score-rest-no-expr/model.rds")
print(non_zero_coefs(model$fit_obj))
cat("\nn_combi:", model$fit_obj$combine_n_max_categorical_features, "\n")
cat("T:", model$fit_obj$time_cutoff, "\n\n")