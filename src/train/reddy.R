# This scripts trains models specified in below src/models on the Reddy 
# training data

library(patroklos)

data <- readRDS("data/reddy/data.rds")
data$cohort <- "train"

model_groups <- c("basic", "ei")
all_models <- list()
for (mg in model_groups) {
    source(paste0("src/models/", mg, ".R"))
    all_models <- c(all_models, for_reddy)
}
prepend_to_directory(all_models, "models/reddy") 
training_camp(all_models, data, skip_on_error = TRUE)
