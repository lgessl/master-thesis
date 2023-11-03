# Apply zero-sum regression for Cox proportional hazards model on Schmitz DLBCL bulk RNAseq data

library(tidyverse)
library(zeroSum)

data_path <- "data/schmitz"
train_dir <- "train"
test_dir <- "test"
expr_fname <- "expr.csv"
pheno_fname <- "pheno.csv"
result_dir <- "results/cox-lasso-zerosum/schmitz"


if(!dir.exists(result_dir))
    dir.create(result_dir, recursive=TRUE)

expr_tr <- read_csv(file.path(data_path, train_dir, expr_fname))
pheno_df <- read_csv(file.path(data_path, train_dir, pheno_fname))
all(colnames(expr_tr) == pheno_df$...1)

# prepare for zerosum
expr_tr <- expr_tr %>% 
    select(!Gene) %>% 
    as.matrix() %>% 
    t()
y <- pheno_df %>%
    select(
        progression_free_survival__pfs__time__yrs, 
        progression_free_survival__pfs__status__0_no_progressoin__1_progression
        ) %>%
    as.matrix()
colnames(y) <- c("pfs_yrs", "pfs_binary")


fit <- zeroSum(
    x = expr_tr,
    y = y,
    family = "cox",
    alpha = 1
)
?zeroSum
