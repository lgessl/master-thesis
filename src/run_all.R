# Run all the scripts in this repo to produce the results of the thesis (or at least similar 
# ones due to randomness in train-test splitting, fitting and validation)

# Preprocess
# source("src/prepro/schmitz.R")
# source("src/prepro/reddy.R")
# source("src/prepro/staiger.R")
# source("src/prepro/all.R")

# Train
source("src/train/schmitz.R")
source("src/train/reddy.R")
source("src/train/staiger.R")
source("src/train/all.R")

# Assess: validate and test
source("src/assess/schmitz.R")
source("src/assess/reddy.R")
source("src/assess/staiger.R")
source("src/assess/all.R")

# Meta analysis
source("src/analyze/feature_selection.R")
source("src/analyze/val_test.R")
source("src/analyze/output_threshold.R")