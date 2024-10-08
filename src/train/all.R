# Train models on combined big data set on each of the three cohorts, respectively

library(patroklos)

data <- readRDS("data/all/data.rds")
source("src/models/all.R")

data$cohort <- "staiger"
prepend_to_directory(models, "models/all/on_staiger")
training_camp(models, data, skip_on_error = FALSE, update_model_shell = FALSE)

source("src/models/all.R")
data$cohort <- "schmitz"
prepend_to_directory(models, "models/all/on_schmitz")
training_camp(models, data, skip_on_error = FALSE, update_model_shell = FALSE)

source("src/models/all.R")
data$cohort <- "reddy"
for (i in seq_along(models)) {
    models[[i]]$time_cutoffs <- models[[i]]$time_cutoffs + 0.5
}
prepend_to_directory(models, "models/all/on_reddy")
training_camp(models, data, skip_on_error = FALSE, update_model_shell = FALSE)