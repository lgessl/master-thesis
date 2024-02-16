# Generate IPI performance table for Schmitz data based on info.json

perf_list <- jsonlite::fromJSON("data/schmitz/info.json")[[c("data", "benchmark", "performance")]]
perf_df <- as.data.frame(perf_list)
rownames(perf_df) <- paste0("IPI >= ", perf_df[["ipi..."]])
perf_df <- perf_df[1:6, 2:3]
names(perf_df) <- c("prevalence", "precision")
c <- print(
    xtable::xtable(
        perf_df, 
        digits = 2, 
        caption = "Filtering PFS < 2 years on \\autocite{schmitz18}.",
        label = "fig:ipi-schmitz"
    )
)
c <- stringr::str_replace_all(c, "\\$>\\$=", "$\\\\geq$")
f <- file("documents/progress-report/figs/ipi_schmitz.tex")
writeLines(c, f)
close(f)
