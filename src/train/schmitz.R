# This scripts trains models specified in below src/models on the Schmitz 
# training data

library(patroklos)

data <- readRDS("data/schmitz/data.rds")
data$cohort <- "train"

model_groups <- c("li", "basic", "ei")
all_models <- list()
for (mg in model_groups) {
    source(paste0("src/models/", mg, ".R"))
    prepend_to_directory(models, "models/schmitz") 
    all_models <- c(all_models, models)
}
training_camp(all_models, data)