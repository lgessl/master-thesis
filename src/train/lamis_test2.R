# This scripts trains models specified in below src/models on the lamis_test2 
# training data

library(patroklos)

data <- readRDS("data/lamis_test2/data.rds")
data$cohort <- "train"

model_groups <- c("basic", "li", "ei")
all_models <- list()
for (mg in model_groups) {
    source(paste0("src/models/", mg, ".R"))
    all_models <- c(all_models, the_best)
}
prepend_to_directory(all_models, "models/lamis_test2") 
training_camp(all_models, data)