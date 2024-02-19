tibble2latex <- function(
    tbl,
    file,
    caption = NULL,
    align = NULL,
    label = NULL,
    digits = NULL,
    display = NULL,
    auto = FALSE
){
    if(!is.null(align)) align <- paste0("r", align)
    c <- print(
        xtable::xtable(
            tbl, 
            digits = digits, 
            caption = caption,
            label = label,
            align = align,
            display = display,
            auto = auto
        ),
        include.rownames = FALSE,
        sanitize.colnames.function = function(x) x,
        file = file
    )
}