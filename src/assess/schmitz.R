# Prevalence versus precision for all models in one plot

cm <- modules::use("src/assess/compare_models.R")


result_dir <- "results" # top-level result directory
all_dir <- "all" # where to store results on all models in the above dir
models <- c(
    "cox-lasso-zerosum",
    "ipi"
)
dataset <- "schmitz"
csv_fname <- "prev_vs_prec.csv"
x_label <- "prevalence"
y_label <- "precision"
plt_title <- NULL
show_plt <- TRUE

plt_title <- cap
plt_fname <- file.path(
    result_dir,
    all_dir,
    stringr::str_replace(csv_fname, "csv", "pdf")
    )
# Generate all csv file names
files <- character(length(models))
names(files) <- models
for(model in models){
    files[model] <- file.path(result_dir, model, dataset, csv_fname)
}

cm$compare_models(
    files,
    plt_fname,
    x_label = x_label,
    y_label = y_label,
    plt_title = plt_title,
    show_plt = show_plt
)
