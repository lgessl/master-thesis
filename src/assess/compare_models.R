# Provide a function that can assess the property1-vs-property2 performance
# of multiple models in a single plot

export("compare_models")

compare_models <- function(
    files,
    plt_fname,
    x_label = "prevalence",
    y_label = "precision",
    plt_title = NULL,
    show_plt = TRUE,
    plt_width = 7,
    plt_height = 4,
    plt_units = "in"
){
    plt_dir <- dirname(plt_fname)
    if(!dir.exists(plt_dir)){
        dir.create(plt_dir, recursive = TRUE)
    }
    # Retrieve all the data frames
    tbl_list = list()
    for(model_name in names(files)){
        tbl_list[[model_name]] = readr::read_csv(files[model_name], )
    }
    tbl <- dplyr::bind_rows(tbl_list, .id = "model")
    colors <- unname(rev(unicol::uni_regensburg_3))
    plt <- ggplot2::ggplot(
        tbl,
        ggplot2::aes(x = .data[[x_label]], y = .data[[y_label]], col = model)
    ) +
    ggplot2::geom_line() +
    ggplot2::geom_point() +
    ggplot2::scale_color_manual(values = colors)
    ggplot2::ggtitle(plt_title)
    if(show_plt){
        print(plt)
    }
    ggplot2::ggsave(plt_fname, plt, width = plt_width, 
        height = plt_height, units = plt_units)
}